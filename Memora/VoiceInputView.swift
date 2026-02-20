import SwiftUI

struct VoiceInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var voiceService = VoiceRecognitionService()

    let onComplete: (String) -> Void

    private var parsedResult: NLPParser.ParsedResult {
        NLPParser().parse(voiceService.transcript)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.large) {
                    VoiceWaveformView(isRecording: voiceService.isRecording)
                        .frame(height: 90)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("TRANSCRIPT")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundStyle(DesignSystem.Colors.accent)

                        ScrollView {
                            Text(voiceService.transcript.isEmpty ? "Start recording and speak..." : voiceService.transcript)
                                .font(DesignSystem.Typography.body)
                                .foregroundStyle(
                                    voiceService.transcript.isEmpty ?
                                        DesignSystem.Colors.textTertiary :
                                        DesignSystem.Colors.textPrimary
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 120)
                        .padding(DesignSystem.Spacing.medium)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }

                    if !voiceService.transcript.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                            Text("PARSED RESULT")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundStyle(DesignSystem.Colors.accent)

                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                                Text("Priority: \(parsedResult.priority.localizedName)")
                                if let dueDate = parsedResult.dueDate {
                                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                                }
                                if !parsedResult.checklistItems.isEmpty {
                                    Text("Checklist items: \(parsedResult.checklistItems.count)")
                                }
                            }
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DesignSystem.Spacing.medium)
                        .background(DesignSystem.Colors.secondaryBackground.opacity(0.8))
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }

                    Button {
                        toggleRecording()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: voiceService.isRecording ?
                                            [DesignSystem.Colors.alert, DesignSystem.Colors.accent] :
                                            [DesignSystem.Colors.accent, DesignSystem.Colors.primary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 84, height: 84)

                            Image(systemName: voiceService.isRecording ? "stop.fill" : "mic.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)

                    Text(voiceService.isRecording ? "Tap to stop recording" : "Tap to start recording")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)

                    if let errorMessage = voiceService.errorMessage {
                        Text(errorMessage)
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.alert)
                    }

                    HStack(spacing: DesignSystem.Spacing.medium) {
                        Button("CANCEL") {
                            voiceService.stopRecording()
                            dismiss()
                        }
                        .buttonStyle(.bordered)

                        Button("SAVE NOTE") {
                            finish()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignSystem.Colors.primary)
                        .disabled(voiceService.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding()
                .frame(minWidth: 460, minHeight: 560)
            }
            .navigationTitle("VOICE INPUT")
            .task {
                _ = await voiceService.requestAuthorization()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggleRecording() {
        if voiceService.isRecording {
            voiceService.stopRecording()
            return
        }

        do {
            try voiceService.startRecording()
        } catch {
            voiceService.errorMessage = error.localizedDescription
        }
    }

    private func finish() {
        let text = voiceService.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        voiceService.stopRecording()
        onComplete(text)
        dismiss()
    }
}

struct VoiceWaveformView: View {
    let isRecording: Bool
    @State private var phase = 0.0

    var body: some View {
        Canvas { context, size in
            let barCount = 28
            let barWidth = size.width / CGFloat(barCount * 2)
            let maxHeight = size.height * 0.82

            for index in 0..<barCount {
                let x = CGFloat(index * 2 + 1) * barWidth
                let progress = CGFloat(index) / CGFloat(barCount)
                let angle = Double(progress) * .pi * 4 + phase
                let wave = sin(angle)
                let normalizedHeight = isRecording ? (0.28 + 0.72 * (0.5 + 0.5 * CGFloat(wave))) : 0.16

                let barHeight = maxHeight * normalizedHeight
                let y = (size.height - barHeight) / 2

                let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let path = RoundedRectangle(cornerRadius: barWidth / 2).path(in: rect)

                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [DesignSystem.Colors.accent.opacity(0.9), DesignSystem.Colors.primary.opacity(0.85)]),
                        startPoint: CGPoint(x: rect.minX, y: rect.minY),
                        endPoint: CGPoint(x: rect.minX, y: rect.maxY)
                    )
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.12).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}
