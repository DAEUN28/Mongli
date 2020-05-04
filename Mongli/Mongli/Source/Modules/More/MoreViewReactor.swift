//
//  MoreViewReactor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import AuthenticationServices

import ReactorKit
import RxCocoa
import RxFlow
import RxSwift

final class MoreViewReactor: Reactor, Stepper {

  enum Action {
    case readAnalysis
    case categoryInfoButtonDidTap
    case accountManagementButtonDidTap
    case opensourceButtonDidTap
    case contactButtonDidTap
  }

  enum Mutation {
    case setDidAnalysisUpdate(Bool)
    case setName(String)
    case setError(LocalizedString?)
  }

  struct State {
    var didAnalysisUpdate: Bool = false
    var name: String = StorageManager.shared.readUser()?.name ?? "몽리"
    var total: Int = StorageManager.shared.readAnalysis()?.total ?? 0
  }

  let initialState: State = .init()
  var steps: PublishRelay<Step> = .init()

  private let service: AuthService
  private let disposeBag: DisposeBag = .init()

  init(_ service: AuthService) {
    self.service = service
  }

  // swiftlint:disable cyclomatic_complexity
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .readAnalysis:
      return service.readAnalysis().asObservable()
        .map {
          switch $0 {
          case .success: return .setDidAnalysisUpdate(true)
          case .error(let error): return .setError(error.message)
          }
      }

    case .categoryInfoButtonDidTap:
      steps.accept(step: .categoryInfoIsRequired)
      return .empty()

    case .accountManagementButtonDidTap:
      let result = PublishRelay<Mutation>()

      let logoutHandler: (UIAlertAction) -> Void = { [weak self] _ in
        guard let self = self else { return }
        AnalyticsManager.view_more_menu_accountManagement_logout.log(nil)
        self.service.logout().asObservable().bind {
          switch $0 {
          case .success: self.steps.accept(step: .signInIsRequired)
          case .error(let error): self.steps.accept(step: .toast(error.message))
          }
        }
        .disposed(by: self.disposeBag)
      }
      let deleteUserHandler: (UIAlertAction) -> Void = { _ in
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
      let renameHandler: (String?) -> Void = { [weak self] in
        guard let self = self, let name = $0 else { return }
        self.service.rename(name).asObservable().bind {
          switch $0 {
          case .success: result.accept(.setName(name))
          case .error(let error): self.steps.accept(step: .toast(error.message))
          }
        }.disposed(by: self.disposeBag)
      }

      steps.accept(step: .accountManagementIsRequired(logoutHandler: logoutHandler,
                                                      deleteUserHandler: deleteUserHandler,
                                                      renameHandler: renameHandler))
      return result.asObservable()

    case .opensourceButtonDidTap:
      steps.accept(step: .opensourceLisenceIsRequired)
      return .empty()

    case .contactButtonDidTap:
      steps.accept(step: .contactIsRequired)
      return .empty()

    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setDidAnalysisUpdate(let didAnalysisUpdate):
      state.didAnalysisUpdate = didAnalysisUpdate
      if didAnalysisUpdate {
        state.total = StorageManager.shared.readAnalysis()?.total ?? state.total
      }

    case .setName(let name):
      state.name = name

    case .setError(let error):
      self.steps.accept(step: .toast(error ?? .unknownErrorMsg))
    }

    return state
  }
}
