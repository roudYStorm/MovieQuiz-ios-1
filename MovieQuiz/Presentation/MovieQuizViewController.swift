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
    
    private var alertPresenter = AlertPresenter()
    private var alertModel: AlertModel?
    
    private var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let fileName = "inception.json"
    
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
        

        documentsURL.appendPathComponent(fileName)
        let jsonString = try? String(contentsOf: documentsURL)
        let movieBase = getMovie(from: jsonString!)
         print(movieBase!)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func getMovie(from jsonString: String) -> Movie? {
        var movie: Movie? = nil
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return nil
            }
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            guard let json = json,
                  let id = json["id"] as? String,
                  let title = json["title"] as? String,
                  let jsonYear = json["year"] as? String,
                  let year = Int(jsonYear),
                  let image = json["image"] as? String,
                  let releaseDate = json["releaseDate"] as? String,
                  let jsonRuntimeMins = json["runtimeMins"] as? String,
                  let runtimeMins = Int(jsonRuntimeMins),
                  let directors = json["directors"] as? String,
                  let actorList = json["actorList"] as? [Any] else {
                return nil
            }

            var actors: [Actor] = []

            for actor in actorList {
                guard let actor = actor as? [String: Any],
                      let id = actor["id"] as? String,
                      let image = actor["image"] as? String,
                      let name = actor["name"] as? String,
                      let asCharacter = actor["asCharacter"] as? String else {
                    return nil
                }
                let mainActor = Actor(id: id,
                                      image: image,
                                      name: name,
                                      asCharacter: asCharacter)
                actors.append(mainActor)
            }
            movie = Movie(id: id,
                          title: title,
                          year: year,
                          image: image,
                          releaseDate: releaseDate,
                          runtimeMins: runtimeMins,
                          directors: directors,
                          actorList: actors)
        } catch {
            print("Failed to parse: \(jsonString)")
        }

        return movie
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
        
        let action = UIAlertAction(title: result.buttonText,
                                   style: .default) {[weak self] _ in
            guard let self = self else { return }
           
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            questionFactory.requestNextQuestion()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            alertModel = alertPresenter.createAlert(correctAnswers: correctAnswers, questionsAmount: questionsAmount)
            guard let alertModel = alertModel else { return }
            self.showAlert(quiz: alertModel)
        } else { // 2
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
