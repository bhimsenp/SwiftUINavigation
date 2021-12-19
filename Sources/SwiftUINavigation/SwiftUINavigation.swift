import SwiftUI

public struct NavigationController: View {
    @ObservedObject var stack: NavigationStack

    public init<Content: View>(@ViewBuilder _ view: @escaping () -> Content) {
        stack = NavigationStack(view())
    }

    public var body: some View {
        UINavVC(stack: stack)
            .environmentObject(stack)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.top, .bottom])
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
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

public class NavigationStack: ObservableObject {
    let navVC: UINavigationController
    var controllers: [UIViewController] {
        return navVC.viewControllers
    }

    init<Content: View>(_ initialPage: Content) {
        navVC = CustomUINavigationController()
        navVC.setViewControllers([initialPage.environmentObject(self).toVC()], animated: false)
    }

    convenience init() {
        self.init(EmptyView())
    }

    public func push<Content: View>(_ page: Content, animated: Bool = true) {
        navVC.pushViewController(page.toVC(), animated: animated)
    }

    public func pop(_ noOfPages: Int = 1, animated: Bool = true) {
        navVC.setViewControllers(Array(navVC.viewControllers[0..<max(1, navVC.viewControllers.count - noOfPages)]), animated: animated)
    }
    
    public func popToRoot(animated: Bool = true) {
        navVC.popToRootViewController(animated: animated)
    }

    public func replace<Content: View>(_ page: Content, animated: Bool = true) {
        navVC.setViewControllers(Array(navVC.viewControllers[0..<(navVC.viewControllers.count - 1)] + [page.toVC()]), animated: animated)
    }

    public func setNavigationBarHidden(_ hidden: Bool) {
        navVC.isNavigationBarHidden = hidden
    }
}

private extension View {
    func toVC() -> UIViewController {
        CustomHostingVC(rootView: self)
    }
}

class CustomHostingVC<Content>: UIHostingController<Content> where Content: View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
