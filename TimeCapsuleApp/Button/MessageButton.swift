//
//  MessageButton.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/10/24.
//

import SwiftUI

struct MessageButton: View {
    
    @Binding var isShowing : Bool
    @State private var curHeight: CGFloat = 400
    @State private var navigateToHome = false
    
    let minHeight: CGFloat = 400
    let maxHeight: CGFloat = 700
    
    var body: some View {
            if isShowing {
                ZStack(alignment: .bottom) {
                    Color.white
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowing = false
                        }
                    mainView
                        .transition(.move(edge: .bottom))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .animation(.easeInOut)
            }
        }

        var mainView: some View {
            VStack {
                ZStack {
                    Capsule()
                        .foregroundColor(.gray)
                        .opacity(0.4)
                        .frame(width: 40, height: 6)
                }
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.00001))
                .gesture(dragGesture)

                ZStack {
                    VStack {
                        Spacer()
                        Image("shake")
                            .padding(.bottom, 20)

                        Text("You can only take a photo a day!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 209)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Spacer()

                        Button(action: {
                            isShowing = false
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 291, height: 62)
                                    .cornerRadius(40)
                                    .foregroundColor(.black)
                                    .shadow(radius: 24, x: 0, y: 14)

                                HStack {
                                    Text("Sounds good")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .frame(maxHeight: .infinity)
                .padding(.bottom, 35)
            }
            .frame(height: 400)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                    Rectangle()
                        .frame(height: 200)
                }
                .foregroundColor(.white))
        }

        @State private var prevDragTranslation = CGSize.zero
        var dragGesture: some Gesture {
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { val in
                    let dragAmount = val.translation.height - prevDragTranslation.height
                    if curHeight > maxHeight || curHeight < minHeight {
                        curHeight -= dragAmount / 6
                    } else {
                        curHeight -= dragAmount
                    }
                    prevDragTranslation = val.translation
                }
                .onEnded { val in
                    prevDragTranslation = .zero
                }
        }
    }

struct MessageButton_Previews: PreviewProvider{
    static var previews: some View {
        CameraController()
    }
}
