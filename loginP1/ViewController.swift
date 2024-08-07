import UIKit

class ViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    let welcomeLabel = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let startButton = UIButton(type: .system)
    let logoutButton = UIButton(type: .system)
    let deleteAccountButton = UIButton(type: .system)
    let viewUserInfoButton = UIButton(type: .system)
    
    let userNumberKey = "userNumber"
    let userEmailKeyPrefix = "userEmail_"
    let userPasswordKeyPrefix = "userPassword_"
    let userLoginStatusKeyPrefix = "userLoginStatus_"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        viewUserInfoButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(startButton)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        view.addSubview(viewUserInfoButton)
        
        welcomeLabel.textAlignment = .center
        emailTextField.placeholder = "이메일 입력"
        emailTextField.borderStyle = .roundedRect
        passwordTextField.placeholder = "비밀번호 입력"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        startButton.setTitle("시작하기", for: .normal)
        logoutButton.setTitle("로그아웃", for: .normal)
        deleteAccountButton.setTitle("회원탈퇴", for: .normal)
        viewUserInfoButton.setTitle("회원정보보기", for: .normal)
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        viewUserInfoButton.addTarget(self, action: #selector(viewUserInfoButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: 200),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            
            viewUserInfoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewUserInfoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            
            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            
            // viewUserInfoButton을 항상 화면 하단에 고정
            viewUserInfoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            viewUserInfoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // 초기 상태에서 버튼을 보이도록 설정
        logoutButton.isHidden = true
        deleteAccountButton.isHidden = true
    }
    
    func updateUI() {
        // 현재 로그인된 유저의 정보 가져오기
        var isLoggedIn = false
        for userNumber in 0..<userDefaults.integer(forKey: userNumberKey) {
            let loginStatusKey = "\(userLoginStatusKeyPrefix)\(userNumber)"
            if userDefaults.bool(forKey: loginStatusKey) {
                let emailKey = "\(userEmailKeyPrefix)\(userNumber)"
                let email = userDefaults.string(forKey: emailKey) ?? ""
                welcomeLabel.text = "\(email)님 환영합니다."
                emailTextField.isHidden = true
                passwordTextField.isHidden = true
                startButton.isHidden = true
                logoutButton.isHidden = false
                deleteAccountButton.isHidden = false
                isLoggedIn = true
                break
            }
        }
        
        // 사용자가 로그인하지 않은 상태일 때
        if !isLoggedIn {
            welcomeLabel.text = "로그인 해주세요"
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            startButton.isHidden = false
            logoutButton.isHidden = true
            deleteAccountButton.isHidden = true
        }
    }
    
    @objc func startButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        // 기존 유저 확인
        for userNumber in 0..<userDefaults.integer(forKey: userNumberKey) {
            let emailKey = "\(userEmailKeyPrefix)\(userNumber)"
            let passwordKey = "\(userPasswordKeyPrefix)\(userNumber)"
            let loginStatusKey = "\(userLoginStatusKeyPrefix)\(userNumber)"
            
            if let storedEmail = userDefaults.string(forKey: emailKey),
               let storedPassword = userDefaults.string(forKey: passwordKey),
               email == storedEmail {
                // 회원이면 로그인
                if password == storedPassword {
                    // 로그인 성공
                    userDefaults.set(true, forKey: loginStatusKey)
                    updateUI()
                    return
                } else {
                    showAlert(message: "비밀번호가 일치하지 않습니다.")
                    return
                }
            }
        }
        
        // 비회원이면 회원가입
        let userNumber = userDefaults.integer(forKey: userNumberKey)
        userDefaults.set(userNumber + 1, forKey: userNumberKey)
        
        let emailKey = "\(userEmailKeyPrefix)\(userNumber)"
        let passwordKey = "\(userPasswordKeyPrefix)\(userNumber)"
        let loginStatusKey = "\(userLoginStatusKeyPrefix)\(userNumber)"
        
        userDefaults.set(email, forKey: emailKey)
        userDefaults.set(password, forKey: passwordKey)
        userDefaults.set(true, forKey: loginStatusKey) // 회원가입 후 자동으로 로그인
        
        updateUI()
    }
    
    @objc func logoutButtonTapped() {
        // 현재 로그인된 유저의 정보를 가져와서 로그인 상태를 false로 설정
        for userNumber in 0..<userDefaults.integer(forKey: userNumberKey) {
            let loginStatusKey = "\(userLoginStatusKeyPrefix)\(userNumber)"
            if userDefaults.bool(forKey: loginStatusKey) {
                userDefaults.set(false, forKey: loginStatusKey)
                break
            }
        }
        updateUI()
    }
    
    @objc func deleteAccountButtonTapped() {
        // 현재 로그인된 유저의 정보를 삭제
        for userNumber in 0..<userDefaults.integer(forKey: userNumberKey) {
            let loginStatusKey = "\(userLoginStatusKeyPrefix)\(userNumber)"
            if userDefaults.bool(forKey: loginStatusKey) {
                // 로그인된 유저의 정보를 삭제
                let emailKey = "\(userEmailKeyPrefix)\(userNumber)"
                let passwordKey = "\(userPasswordKeyPrefix)\(userNumber)"
                
                userDefaults.removeObject(forKey: emailKey)
                userDefaults.removeObject(forKey: passwordKey)
                userDefaults.removeObject(forKey: loginStatusKey)
                
                // 로그인 상태를 false로 설정
                break
            }
        }
        updateUI()
    }
    
    @objc func viewUserInfoButtonTapped() {
        var userInfoString = "회원정보:\n\n"
        
        // 모든 유저 정보를 가져와서 문자열로 변환
        for userNumber in 0..<userDefaults.integer(forKey: userNumberKey) {
            let emailKey = "\(userEmailKeyPrefix)\(userNumber)"
            let passwordKey = "\(userPasswordKeyPrefix)\(userNumber)"
            let loginStatusKey = "\(userLoginStatusKeyPrefix)\(userNumber)"
            
            if let email = userDefaults.string(forKey: emailKey),
               let password = userDefaults.string(forKey: passwordKey) {
                let loginStatus = userDefaults.bool(forKey: loginStatusKey) ? "로그인됨" : "로그아웃됨"
                userInfoString += "유저 \(userNumber): 이메일: \(email), 비밀번호: \(password), 상태: \(loginStatus)\n"
            }
        }
        
        showAlert(message: userInfoString)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

