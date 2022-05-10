import SwiftUI

import SwiftUI

public struct NavigationController: View {
    @ObservedObject var stack: NavigationStack
    let edgesIgnoringSafeArea: Edge.Set

    public init<Content: View>(@ViewBuilder _ view: @escaping () -> Content, edgesIgnoringSafeArea: Edge.Set = []) {
        stack = NavigationStack(view())
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
    }

    public var body: some View {
        let vc = UINavVC(stack: stack)
            .environmentObject(stack)
            .edgesIgnoringSafeArea(edgesIgnoringSafeArea)
        if #available(iOS 15.0, *) {
            vc
        } else {
            vc.navigationBarHidden(true)
        }
    }
}

struct UINavVC: UIViewControllerRepresentable {
    let stack: NavigationStack

    func makeUIViewController(context: Context) -> UINavigationController {
        return stack.navVC
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {

    }
}

class CustomUINavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        navigationBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.isHidden = true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

public class NavigationStack: ObservableObject {
    public let navVC: UINavigationController
    public var controllers: [UIViewController] {
        return navVC.viewControllers
    }

    public init<Content: View>(_ initialPage: Content) {
        navVC = CustomUINavigationController()
        navVC.setViewControllers([initialPage.toVC(self)], animated: false)
    }

    public init() {
        navVC = CustomUINavigationController()
    }

    public func push<Content: View>(_ page: Content, animated: Bool = true) {
        navVC.pushViewController(page.toVC(self), animated: animated)
    }

    public func pop(_ noOfPages: Int = 1, animated: Bool = true) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        navVC.setViewControllers(Array(navVC.viewControllers[0..<max(1, navVC.viewControllers.count - noOfPages)]), animated: animated)
    }

    public func popToRoot(animated: Bool = true) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        navVC.popToRootViewController(animated: animated)
    }

    public func replace<Content: View>(_ page: Content, animated: Bool = true) {
        navVC.setViewControllers(Array(navVC.viewControllers[0..<(navVC.viewControllers.count - 1)] + [page.toVC(self)]), animated: animated)
    }

    public func makeRoot<Content: View>(_ page: Content, animated: Bool = true) {
        navVC.setViewControllers([page.toVC(self)], animated: animated)
    }
}

private extension View {
    func toVC(_ stack: NavigationStack) -> UIViewController {
        if #available(iOS 15.0, *) {
            return CustomHostingVC(rootView: self.environmentObject(stack))
        } else {
            return CustomHostingVC(rootView: self.environmentObject(stack).navigationBarHidden(true))
        }
    }
}

class CustomHostingVC<Content>: UIHostingController<Content> where Content: View {

}
