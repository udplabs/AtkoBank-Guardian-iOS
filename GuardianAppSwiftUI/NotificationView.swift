import SwiftUI
import Combine
import Guardian
import JWTDecode
import LocalAuthentication

struct NotificationView: View {
    @EnvironmentObject var notificationCenter: NotificationCenter
    @State var browserLabel: String = "Unknown"
    @State var osLabel: String = "Unknown"
    @State var location: Location? = nil
    @State var dateLabel: String = ""
    @State var notificationText: String = ""
    @State var transferType: String = ""
    @State var transferFrom: String = ""
    @State var transferTo: String = ""
    @State var paymentAmount: String = ""
    @State var username: String = ""
    @State var tenant: String = ""
    @State private var showBiometricPrompt = false
    @State private var authenticationError: Error? = nil
    @State private var isButtonEnabled = true
    //@State private var showAllowAlert = false
    @State private var timerAllow: Timer? = nil
    @State private var requiresPINVerification: Bool = false
    @State private var showPINVerification: Bool = false
    @State private var pin: String = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.blue.opacity(0.10)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    Image(systemName: "building.columns")
                        .font(.system(size: 100))
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Image("oktalogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64) // Adjust the size as needed
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        HStack {
                            Text("Action")
                                .font(.title)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        if (transferType != "") {
                            HStack {
                                Text(transferType)
                                    .font(.title2)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            HStack {
                                Text(transferFrom)
                                Image(systemName: "arrow.right")
                                Text(transferTo)
                            }
                            .frame(maxWidth: .infinity)
                            HStack {
                                Image(systemName: "dollarsign")
                                Text(paymentAmount)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            HStack {
                                Text("Login")
                                    .font(.title2)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    //.border(.cyan)
                    Group {
                        HStack () {
                            Text("Security Context")
                                .font(.title)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        //.border(.red)
                        HStack () {
                            Image(systemName: "location.fill")
                                .imageScale(.large)
                            Text(location?.name ?? "Kansas City, MO")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        //.border(.red)
                        HStack {
                            Image(systemName: "desktopcomputer")
                                .imageScale(.large)
                            Text(osLabel)
                            Spacer()
                            Image(systemName: "globe")
                                .imageScale(.large)
                            Text(browserLabel)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        //.border(.green)
                        HStack (alignment: .firstTextBaseline) {
                            Image(systemName: "clock")
                                .imageScale(.large)
                            Text(dateLabel)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        //.border(.purple)
                    }
                    //Spacer()
                    Group {
                        Text("Is this you?")
                            .font(.title)
                            .padding(.vertical)
                        HStack(spacing: 50) {
                            Button(action: {
                                guard isButtonEnabled else { return } // Check if the button is already disabled
                                isButtonEnabled = false // Disable the button
                                if(!self.requiresPINVerification) {
                                    self.showBiometricPrompt = true
                                    self.showPINVerification = false
                                }
                                else  {
                                    self.showPINVerification = true
                                }
                            }) {
                                Text("Yes")
                                    .font(.headline)
                                    .frame(width: 130, height: 50)
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                            }
                            .disabled(!isButtonEnabled)
                            
                            Button(action: {
                                self.denyAction(enrollment: GuardianState.loadByEnrollmentId(by: notificationCenter.authenticationNotification!.enrollmentId))
                            }) {
                                Text("No")
                                    .font(.headline)
                                    .frame(width: 130, height: 50)
                                    .background(Color.red)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        //.border(.cyan)
                    }
                }
                .padding()
                .background()
                .cornerRadius(10)
                //.border(.secondary)
                .shadow(radius: 10)
                .alert(isPresented: $showBiometricPrompt) {
                                    biometricPrompt
                                }
                Spacer()
 
            }
            //.border(.yellow)
            

//            if showAllowAlert {
//                Text("Transaction Approved!")
//                    .font(.title)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.0)))
//                    .zIndex(3)
//
//                Color.clear
//                    .background(BlurView(style: .prominent))
//                    .contentShape(Rectangle())
//                    .onTapGesture {}
//                    .zIndex(2)
//            }
        }
        .onAppear {
            if notificationCenter.authenticationNotification != nil {
                self.loadData(enrollment: GuardianState.loadByEnrollmentId(by: notificationCenter.authenticationNotification!.enrollmentId))
            } else {
                dateLabel = Date().formatted(date: .abbreviated, time: Date.FormatStyle.TimeStyle.standard)
                location = nil
                browserLabel = "Chrome xyx"
                osLabel = "Windows 11"
                username = "les.claypool@atko.email"
                tenant = "atko.email"
                transferType = "Transfer"
                transferFrom = "Checking XXXX1234"
                transferTo = "Savings XXXX5678"
                paymentAmount = "1234.56"
                notificationText = "\(paymentAmount) from \(transferFrom) to \(transferTo)"
            }
        }
        .sheet(isPresented: $showPINVerification, onDismiss: {
            isButtonEnabled = true
        }) {
            PINVerificationView(pin: $pin, enrollment: GuardianState.loadByEnrollmentId(by: notificationCenter.authenticationNotification!.enrollmentId)!) { isPINVerified  in
                if isPINVerified {
                    self.allowAction(enrollment: GuardianState.loadByEnrollmentId(by: notificationCenter.authenticationNotification!.enrollmentId))
                    //self.showAllowAlert = true

                    self.timerAllow?.invalidate()
                    self.timerAllow = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        //self.showAllowAlert = false
                        notificationCenter.authenticationNotification = nil
                        self.requiresPINVerification = false
                        self.showPINVerification = false
                    }
                } else {
                    // Handle incorrect PIN
                    // For example, show an error message
                    print("Incorrect PIN")
                }
            }
        }
        
    }

    private var biometricPrompt: Alert {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            authenticationError = error
            showBiometricPrompt = false
            isButtonEnabled = true
            return Alert(title: Text("Error"), message: Text(error?.localizedDescription ?? "Failed to evaluate biometric policy."), dismissButton: .default(Text("OK")))
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to allow the action") { success, error in
            DispatchQueue.main.async {
                if success {
                    self.allowAction(enrollment: GuardianState.loadByEnrollmentId(by: notificationCenter.authenticationNotification!.enrollmentId))
                    //self.showAllowAlert = true

                    self.timerAllow?.invalidate()
                    self.timerAllow = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
                        //self.showAllowAlert = false
                        notificationCenter.authenticationNotification = nil
                    }
                } else if let error = error {
                    self.authenticationError = error
                }
                self.showBiometricPrompt = false
            }
        }

        return Alert(title: Text("Biometric Authentication"), message: Text("Authenticate to allow the action"), dismissButton: .default(Text("Cancel")))
    }

    func loadData(enrollment: GuardianState?) {
        guard let notification = notificationCenter.authenticationNotification, let enrollment = enrollment else {
            return
        }
        browserLabel = notification.source?.browser?.name ?? "Unknown"
        osLabel = notification.source?.os?.name ?? "Unknown"
        location = notification.location!
        dateLabel = "\(notification.startedAt.formatted(date: .abbreviated, time: Date.FormatStyle.TimeStyle.standard))"
        self.username = enrollment.userEmail
        self.tenant = enrollment.enrollmentTenantDomain

        // This part of the code is custom to get the Authorization details
        if notification.txlnkid != nil {
            if let url = URL(string: "https://okta-ciam-demo-default-rtdb.firebaseio.com/message/".appending(notification.txlnkid!).appending(".json")) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let res = try JSONDecoder().decode(AuthorizationDetails.self, from: data)
                            DispatchQueue.main.async {
                                self.transferType = res.type
                                self.paymentAmount = String(format: "%.2f", res.amount)
                                self.transferFrom = res.from
                                self.transferTo = res.to
                                self.requiresPINVerification = !(enrollment.enrollmentPIN ?? "").isEmpty
                                self.notificationText = "\(transferType): \(paymentAmount) from \(transferFrom) to \(transferTo)"
                            }
                        } catch let error {
                            print(error)
                            // this is a regular login, one w/out any authorization details
                            self.notificationText = "Login"
                        }
                    }
                }.resume()
            }
        }
    }

    func allowAction(enrollment: GuardianState?) {
        guard let notification = notificationCenter.authenticationNotification, let enrollment = enrollment else {
            notificationCenter.authenticationNotification = nil
            return
        }
        let request = Guardian
            .authentication(forDomain: enrollment.enrollmentTenantDomain, device: enrollment)
            .allow(notification: notification)
        debugPrint(request)
        request.start { result in
            print(result)
            switch result {
            case .success:
                print("Allow Success")
            case .failure(let cause):
                print("Allow failed \(cause)")
            }
        }
    }

    func denyAction(enrollment: GuardianState?) {
        guard let notification = notificationCenter.authenticationNotification, let enrollment = enrollment else {
            notificationCenter.authenticationNotification = nil
            return
        }
        let request = Guardian
            .authentication(forDomain: enrollment.enrollmentTenantDomain, device: enrollment)
            .reject(notification: notification, withReason: "User rejected the notification!")
        debugPrint(request)
        request.start { result in
            print(result)
            switch result {
            case .success:
                print("User rejected the request!")
                DispatchQueue.main.async {
                    notificationCenter.authenticationNotification = nil
                }
            case .failure(let cause):
                print("Reject failed \(cause)")
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            .environmentObject(NotificationCenter())
    }
}

struct AuthorizationDetails: Codable {
    let from: String
    let to: String
    let amount: Float
    //let transaction_id: String
    let type: String
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

