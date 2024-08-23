//
//  ImagePreview.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/12/24.
//

import SwiftUI

struct ImagePreview: View {

    struct Person: Identifiable {
        let id: UUID = UUID()
        let first: String
        let last: String
    }

    @Namespace private var animationNamespace
    @State private var selectedPerson: Person? = nil
    private let detailId = UUID()
    private let cardWidth: CGFloat = 70

    let people: [Person] = [
        Person(first: "John", last: "Doe"),
        Person(first: "Jane", last: "Doe"),
        Person(first: "Fred", last: "Doe"),
        Person(first: "Bill", last: "Doe"),
        Person(first: "Jack", last: "Doe"),
        Person(first: "Mary", last: "Doe"),
        Person(first: "Peter", last: "Doe"),
        Person(first: "Anne", last: "Doe"),
        Person(first: "Tina", last: "Doe"),
        Person(first: "Tom", last: "Doe")
    ]

    private func personView(person: Person) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .foregroundStyle(.gray)
            .shadow(radius: 5)
            .overlay {
                Text(person.first)
            }
//            .opacity(selectedPerson == nil || selectedPerson?.id == person.id ? 1 : 0)
            .matchedGeometryEffect(
                id: selectedPerson?.id == person.id ? detailId : person.id,
                in: animationNamespace,
                isSource: false
            )
    }

    private var floatingPersonViews: some View {
        ForEach(people) { person in
            personView(person: person)
                .allowsHitTesting(false)
        }
    }

    private var cardBases: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(people) { person in
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: cardWidth, height: 100)
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                                selectedPerson = person
                            }
                        }
                        .matchedGeometryEffect(
                            id: person.id,
                            in: animationNamespace,
                            isSource: true
                        )
                }
            }
            .padding()
        }
    }

    private var homeView: some View {
        ScrollView {
            VStack {
                cardBases
            }
        }
    }

    private var detailBase: some View {
        Rectangle()
            .frame(width: cardWidth, height: 300)
            .opacity(0)
            .matchedGeometryEffect(
                id: detailId,
                in: animationNamespace,
                isSource: true
            )
    }

    private var detailView: some View {
        VStack {
            detailBase
            if let selectedPerson {
                Text(selectedPerson.first + " " + selectedPerson.last)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                selectedPerson = nil
            }
        }
    }

    var body: some View {
        ZStack {
            homeView
            detailView
            floatingPersonViews
        }
    }
}

#Preview {
    ImagePreview()
}
