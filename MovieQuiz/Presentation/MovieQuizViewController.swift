import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {

    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var questionTitleLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
                      return
                  }
                  let givenAnswer = false
                  
                  showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
                       return
                   }
                   let givenAnswer = true
                   
                   showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)

    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var alertPresenter: AlertPresenter?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter(delegate: self)
        alertPresenter?.delegate = self  // устанавливаем связь презентора с делегатом
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        super.viewDidLoad()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        hideLoadingIndicator() // вызываем функцию скрытия индикатор загрузки
        questionFactory?.requestNextQuestion() // делаем запрос к фабрике вопросов для загрузки следующего вопроса с сервера.
    }
        func didFailToLoadData(with error: Error) {
            hideLoadingIndicator()
            showNetworkError(message: error.localizedDescription)
        }
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
        // MARK: - AlertPresenterDelegate
        
        func showAlert(alert: UIAlertController) {
            hideLoadingIndicator() // скрываем индикатор перед показом алерты
            self.present(alert, animated: true)
        }
        // MARK: - Private
        private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
        private func hideLoadingIndicator() { // добавляем функцию которая будет скрывать индикатор
        activityIndicator.isHidden = true // указываем что индикатор загрузки скрыт
        activityIndicator.stopAnimating()
    }
        private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
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
    private func showNetworkError(message: String) {
        // hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "У вас что-то не так",
                               text: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(alertModel: model)
    }
    private func show(quiz result: QuizResultViewModel) {
            // hideLoadingIndicator() // скрываем индикатор
            let alertModel  = AlertModel(title: result.title,
                                text: result.text,
                                buttonText: result.buttonText,
                                buttonAction: {[ weak self ] in
                                guard let self = self else {
                                return
        }
                                self.currentQuestionIndex = 0
                                self.correctAnswers = 0
                                self.questionFactory?.requestNextQuestion()
            })

            alertPresenter?.showAlert(alertModel: alertModel)
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
            let viewModel = QuizResultViewModel(title: "Этот раунд окончен!",
                                                           text: text,
                                                           buttonText: "Сыграть ещё раз")
                show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
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
                
                questionFactory?.requestNextQuestion()
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
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
    

