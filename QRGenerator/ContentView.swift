//
//  ContentView.swift
//  QRGenerator
//
//  Created by Masakazu Sano on 2025/11/19.
//

import SwiftUI

struct ContentView: View {
    @State private var urlString: String = ""
    @State private var showingSaveAlert = false
    @State private var saveError: String?
    
    var body: some View {
        VStack {
            TextField("URLを入力", text: $urlString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let uiImage = generateQRCode(from: urlString) {
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            } else {
                Text("QRコードを生成できませんでした")
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                saveScreenAsImage()
            }) {
                Text("画像を保存")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text(saveError == nil ? "保存完了" : "エラー"),
                message: Text(saveError ?? "画像を写真ライブラリに保存しました"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func saveScreenAsImage() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else {
            saveError = "ウィンドウの取得に失敗しました"
            showingSaveAlert = true
            return
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        saveError = nil
        showingSaveAlert = true
    }
}

extension ContentView {
    func generateQRCode(from string: String) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return nil }

        let scaleX = 10.0
        let scaleY = 10.0
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    ContentView()
}
