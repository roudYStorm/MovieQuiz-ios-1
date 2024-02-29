//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Yulianna on 29.02.2024.
//
import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showAlert(alert: UIAlertController) {
    }
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
    }

    func show(quiz result: MovieQuiz.QuizResultViewModel) {
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
    }

    func showLoadingIndicator() {
    }

    func hideLoadingIndicator() {
    }
    func changeStateButtons(isEnable: Bool) {
    }
    func showNetworkError(message: String) {
    }

}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }

}
