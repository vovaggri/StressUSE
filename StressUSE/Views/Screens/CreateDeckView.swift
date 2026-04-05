import SwiftUI

struct CreateDeckView: View {
    private enum Field: Hashable {
        case title
        case subtitle
        case topic(UUID)
        case prompt(UUID)
        case hint(UUID)
        case option(questionID: UUID, optionID: UUID)
    }

    @Bindable var viewModel: CreateDeckViewModel
    let onClose: () -> Void
    let onSave: (QuestionDeck) -> Void
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    introCard
                    deckMetaCard

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Вопросы")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Spacer()

                            Button(action: viewModel.addQuestion) {
                                Label("Добавить", systemImage: "plus")
                                    .font(.subheadline.weight(.bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(.white.opacity(0.12), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                        }

                        ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                            questionEditor(questionNumber: index + 1, question: question)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 96)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded {
                    focusedField = nil
                }
            )
        }
        .navigationTitle("Новый набор")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Закрыть", action: onClose)
                    .foregroundStyle(.white)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Сохранить") {
                    if let deck = viewModel.buildDeck() {
                        onSave(deck)
                    }
                }
                .fontWeight(.bold)
                .foregroundStyle(.white)
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Готово") {
                    focusedField = nil
                }
                .fontWeight(.bold)
            }
        }
        .alert("Не хватает данных", isPresented: errorBinding) {
            Button("Ок", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Собери свой stress-набор")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Выбери предмет, заполни карточки и сохрани набор. После этого он появится рядом со встроенными вариантами и будет работать в обычном режиме тренировки.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var deckMetaCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            editorField(
                title: "Название набора",
                text: $viewModel.title,
                prompt: "Например, Русский: мои сложные задания",
                field: .title
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Предмет")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Picker("Предмет", selection: $viewModel.selectedSubjectID) {
                    ForEach(viewModel.subjects) { subject in
                        Text(subject.name).tag(subject.id)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            editorField(
                title: "Описание набора",
                text: $viewModel.subtitle,
                prompt: "Коротко опиши, что тренирует этот набор",
                field: .subtitle
            )
        }
        .padding(20)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func questionEditor(questionNumber: Int, question: CreateDeckViewModel.DraftQuestion) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Вопрос \(questionNumber)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Отметь правильные варианты переключателем справа.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer()

                if viewModel.questions.count > 1 {
                    Button(role: .destructive) {
                        viewModel.removeQuestion(id: question.id)
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline.weight(.bold))
                            .padding(10)
                            .background(.white.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }
            }

            editorField(
                title: "Тема",
                text: binding(for: question.id, keyPath: \.topic),
                prompt: "Например, Паронимы",
                field: .topic(question.id)
            )

            editorField(
                title: "Формулировка вопроса",
                text: binding(for: question.id, keyPath: \.prompt),
                prompt: "Напиши сам вопрос",
                field: .prompt(question.id)
            )

            editorField(
                title: "Подсказка",
                text: binding(for: question.id, keyPath: \.hint),
                prompt: "Например, Можно выбрать несколько вариантов.",
                field: .hint(question.id)
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Варианты ответа")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: { viewModel.addOption(to: question.id) }) {
                        Label("Ещё вариант", systemImage: "plus")
                            .font(.footnote.weight(.bold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.orange)
                }

                ForEach(question.options) { option in
                    optionEditor(questionID: question.id, option: option)
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func optionEditor(questionID: UUID, option: CreateDeckViewModel.DraftOption) -> some View {
        HStack(alignment: .top, spacing: 12) {
            TextField(
                "Текст варианта",
                text: optionTextBinding(questionID: questionID, optionID: option.id),
                axis: .vertical
            )
            .lineLimit(2...5)
            .focused($focusedField, equals: .option(questionID: questionID, optionID: option.id))
            .submitLabel(.done)
            .textInputAutocapitalization(.sentences)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .foregroundStyle(.white)
            .onSubmit {
                focusedField = nil
            }

            Toggle(
                "",
                isOn: optionCorrectBinding(questionID: questionID, optionID: option.id)
            )
            .labelsHidden()
            .tint(.orange)
            .padding(.top, 12)

            if optionRemovable(questionID: questionID) {
                Button(role: .destructive) {
                    viewModel.removeOption(questionID: questionID, optionID: option.id)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.72))
                .padding(.top, 10)
            }
        }
    }

    private func editorField(title: String, text: Binding<String>, prompt: String, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            TextField(prompt, text: text, axis: .vertical)
                .lineLimit(2...6)
                .focused($focusedField, equals: field)
                .submitLabel(.done)
                .textInputAutocapitalization(.sentences)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .foregroundStyle(.white)
                .onSubmit {
                    focusedField = nil
                }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.errorMessage = nil
                }
            }
        )
    }

    private func binding(for questionID: UUID, keyPath: WritableKeyPath<CreateDeckViewModel.DraftQuestion, String>) -> Binding<String> {
        Binding(
            get: {
                viewModel.questions.first(where: { $0.id == questionID })?[keyPath: keyPath] ?? ""
            },
            set: { newValue in
                guard let index = viewModel.questions.firstIndex(where: { $0.id == questionID }) else { return }
                viewModel.questions[index][keyPath: keyPath] = newValue
            }
        )
    }

    private func optionTextBinding(questionID: UUID, optionID: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let questionIndex = viewModel.questions.firstIndex(where: { $0.id == questionID }),
                      let optionIndex = viewModel.questions[questionIndex].options.firstIndex(where: { $0.id == optionID }) else {
                    return ""
                }
                return viewModel.questions[questionIndex].options[optionIndex].text
            },
            set: { newValue in
                guard let questionIndex = viewModel.questions.firstIndex(where: { $0.id == questionID }),
                      let optionIndex = viewModel.questions[questionIndex].options.firstIndex(where: { $0.id == optionID }) else {
                    return
                }
                viewModel.questions[questionIndex].options[optionIndex].text = newValue
            }
        )
    }

    private func optionCorrectBinding(questionID: UUID, optionID: UUID) -> Binding<Bool> {
        Binding(
            get: {
                guard let questionIndex = viewModel.questions.firstIndex(where: { $0.id == questionID }),
                      let optionIndex = viewModel.questions[questionIndex].options.firstIndex(where: { $0.id == optionID }) else {
                    return false
                }
                return viewModel.questions[questionIndex].options[optionIndex].isCorrect
            },
            set: { newValue in
                guard let questionIndex = viewModel.questions.firstIndex(where: { $0.id == questionID }),
                      let optionIndex = viewModel.questions[questionIndex].options.firstIndex(where: { $0.id == optionID }) else {
                    return
                }
                viewModel.questions[questionIndex].options[optionIndex].isCorrect = newValue
            }
        )
    }

    private func optionRemovable(questionID: UUID) -> Bool {
        viewModel.questions.first(where: { $0.id == questionID })?.options.count ?? 0 > 2
    }
}

#Preview {
    NavigationStack {
        CreateDeckView(
            viewModel: CreateDeckViewModel(),
            onClose: {},
            onSave: { _ in }
        )
    }
}
