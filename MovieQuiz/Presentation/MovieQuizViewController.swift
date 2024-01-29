import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var questionTitleLabel: UILabel!
    
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    @IBOutlet var questionLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    private var alertPresenter = AlertPresenter()
    private var alertModel: AlertModel?
    
    override func viewDidLoad() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20
        
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        alertPresenter.delegate = self
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func showAlert(quiz result: AlertModel) {
           let alert = UIAlertController(
               title: result.title,
               message: result.text,
               preferredStyle: .alert)
           
           let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
               
               guard let self = self else { return }
               
               self.currentQuestionIndex = 0
               self.correctAnswers = 0
               
               questionFactory.requestNextQuestion()
           }
           
           alert.addAction(action)
           
           self.present(alert, animated: true, completion: nil)
       }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor =
        UIColor.ypBlack.cgColor
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?
        UIColor.ypGreen.cgColor:
        UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let quizCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let formattedAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(quizCount)
                            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                            Средняя точность: \(formattedAccuracy)
                            """
            alertModel = alertPresenter.createAlert(message: text)
            guard let alertModel = alertModel else { return }
            self.showAlert(quiz: alertModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
        }
        
        /*
         Mock-данные
         
         
         Картинка: The Godfather
         Настоящий рейтинг: 9,2
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: The Dark Knight
         Настоящий рейтинг: 9
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: Kill Bill
         Настоящий рейтинг: 8,1
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: The Avengers
         Настоящий рейтинг: 8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: Deadpool
         Настоящий рейтинг: 8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: The Green Knight
         Настоящий рейтинг: 6,6
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: ДА
         
         
         Картинка: Old
         Настоящий рейтинг: 5,8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         
         
         Картинка: The Ice Age Adventures of Buck Wild
         Настоящий рейтинг: 4,3
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         
         
         Картинка: Tesla
         Настоящий рейтинг: 5,1
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         
         
         Картинка: Vivarium
         Настоящий рейтинг: 5,8
         Вопрос: Рейтинг этого фильма больше чем 6?
         Ответ: НЕТ
         */
    }
}
