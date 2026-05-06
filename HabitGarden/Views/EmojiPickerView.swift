//
//  EmojiPickerView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-06.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    let categories: [(name: String, icon: String, emojis: [String])] = [
        ("Smileys", "\u{1F600}", [
            "\u{1F600}","\u{1F603}","\u{1F604}","\u{1F601}","\u{1F606}","\u{1F972}","\u{1F605}","\u{1F923}","\u{1F602}","\u{1F642}",
            "\u{1F60A}","\u{1F607}","\u{1F970}","\u{1F60D}","\u{1F929}","\u{1F618}","\u{1F60B}","\u{1FAD6}","\u{1FAD8}","\u{1F914}",
            "\u{1F610}","\u{1F611}","\u{1F636}","\u{1FAE3}","\u{1F60F}","\u{1F612}","\u{1F644}","\u{1F62C}","\u{1F62E}\u{200D}\u{1F4A8}","\u{1F925}"
        ]),
        ("People", "\u{1F64B}", [
            "\u{1F4AA}","\u{1F91A}","\u{1F590}\u{FE0F}","\u{270B}","\u{1F596}","\u{1F44B}","\u{1F919}","\u{270D}\u{FE0F}","\u{1F64F}","\u{1F91D}",
            "\u{1F9E0}","\u{1F440}","\u{1F441}\u{FE0F}","\u{1FAC0}","\u{1FAC1}","\u{1F9B4}","\u{1F476}","\u{1F9D1}","\u{1F469}","\u{1F468}",
            "\u{1F9D3}","\u{1F64B}","\u{1F646}","\u{1F645}","\u{1F481}","\u{1F647}","\u{1F937}","\u{1F9CF}","\u{1F486}","\u{1F487}"
        ]),
        ("Nature", "\u{1F331}", [
            "\u{1F331}","\u{1F33F}","\u{1F340}","\u{1F335}","\u{1F332}","\u{1F333}","\u{1F334}","\u{1F337}","\u{1F338}","\u{1F339}",
            "\u{1F33A}","\u{1F33B}","\u{1F33C}","\u{1F490}","\u{1FAB7}","\u{1FAB7}","\u{1F344}","\u{1F436}","\u{1F431}","\u{1F42D}",
            "\u{1F439}","\u{1F430}","\u{1F98A}","\u{1F43B}","\u{1F43C}","\u{1F428}","\u{1F42F}","\u{1F981}","\u{1F438}","\u{1F98B}"
        ]),
        ("Food", "\u{1F34E}", [
            "\u{1F34E}","\u{1F34A}","\u{1F34B}","\u{1F34C}","\u{1F349}","\u{1F347}","\u{1F353}","\u{1FAD0}","\u{1F351}","\u{1F96D}",
            "\u{1F34D}","\u{1F965}","\u{1F95D}","\u{1F345}","\u{1F951}","\u{1F966}","\u{1F96C}","\u{1F33D}","\u{1F955}","\u{1F9C4}",
            "\u{2615}","\u{1F375}","\u{1F9C3}","\u{1F964}","\u{1F37A}","\u{1F377}","\u{1F942}","\u{1F370}","\u{1F9C1}","\u{1F369}"
        ]),
        ("Activities", "\u{26BD}", [
            "\u{26BD}","\u{1F3C0}","\u{1F3C8}","\u{26BE}","\u{1F3BE}","\u{1F3D0}","\u{1F3D3}","\u{1F3F8}","\u{1F94A}","\u{1F3AF}",
            "\u{1F3CB}\u{FE0F}","\u{1F938}","\u{1F6B4}","\u{1F3C3}","\u{1F9D8}","\u{1F3CA}","\u{1F9D7}","\u{1F3C4}","\u{1F3AE}","\u{1F3B2}",
            "\u{1F3B5}","\u{1F3B8}","\u{1F3B9}","\u{1F3A8}","\u{1F3AD}","\u{1F3C6}","\u{1F947}","\u{1F948}","\u{1F949}","\u{1F3AA}"
        ]),
        ("Travel", "\u{2708}\u{FE0F}", [
            "\u{1F697}","\u{1F695}","\u{1F68C}","\u{1F3CE}","\u{1F693}","\u{1F691}","\u{1F692}","\u{2708}\u{FE0F}","\u{1F680}","\u{1F6F8}",
            "\u{1F3E0}","\u{1F3E2}","\u{1F3E5}","\u{1F3EB}","\u{26EA}","\u{1F54C}","\u{1F5FC}","\u{1F5FD}","\u{26E9}\u{FE0F}","\u{1F30D}",
            "\u{1F305}","\u{1F304}","\u{1F3D4}","\u{26F0}\u{FE0F}","\u{1F3D6}\u{FE0F}","\u{1F3D5}\u{FE0F}","\u{1F30B}","\u{1F5FB}","\u{1F3DC}\u{FE0F}","\u{1F30A}"
        ]),
        ("Objects", "\u{1F4A1}", [
            "\u{231A}","\u{1F4F1}","\u{1F4BB}","\u{2328}\u{FE0F}","\u{1F5A5}\u{FE0F}","\u{1F4F7}","\u{1F526}","\u{1F4A1}","\u{1F527}","\u{1F528}",
            "\u{1F48A}","\u{1FA7A}","\u{1F4DA}","\u{1F4D6}","\u{1F4DD}","\u{270F}\u{FE0F}","\u{1F58A}\u{FE0F}","\u{1F4CC}","\u{1F4CE}","\u{1F511}",
            "\u{1F4B0}","\u{1F4B3}","\u{1F48E}","\u{1F6D2}","\u{1F381}","\u{1F388}","\u{1FA84}","\u{1F514}","\u{1F4E3}","\u{1F4AC}"
        ]),
        ("Symbols", "\u{2764}\u{FE0F}", [
            "\u{2764}\u{FE0F}","\u{1F9E1}","\u{1F49B}","\u{1F49A}","\u{1F499}","\u{1F49C}","\u{1F5A4}","\u{1F90D}","\u{1F4AF}","\u{2705}",
            "\u{274C}","\u{2B55}","\u{1F4A2}","\u{2668}\u{FE0F}","\u{1F525}","\u{2B50}","\u{1F31F}","\u{2728}","\u{1F4AB}","\u{1F4A5}",
            "\u{26A1}","\u{1F506}","\u{2600}\u{FE0F}","\u{1F308}","\u{2601}\u{FE0F}","\u{2744}\u{FE0F}","\u{1F4A7}","\u{1F30A}","\u{267B}\u{FE0F}","\u{1F530}"
        ])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(categories, id: \.name) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(category.icon) \(category.name)")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                                ForEach(category.emojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.title)
                                        .padding(6)
                                        .background(
                                            selectedEmoji == emoji
                                                ? Color.accentColor.opacity(0.3)
                                                : Color.clear
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .onTapGesture {
                                            selectedEmoji = emoji
                                            dismiss()
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
