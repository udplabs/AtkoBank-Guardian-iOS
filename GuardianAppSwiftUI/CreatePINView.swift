//
//  CreatePINView.swift
//  GuardianAppSwiftUI
//
//  Created by Pushp Abrol on 6/26/23.
//

import SwiftUI
import Guardian
//import PasscodeField

struct CreatePINView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var pin: String = ""
    @State private var reEnterPin: String = ""
    
    var enrollment: GuardianState
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.blue.opacity(0.10)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Image("oktalogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64) // Adjust the size as needed
                        .padding(.horizontal)
                }
                .padding()
                
                VStack {
                    Text("Create a PIN to protect your access")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    PasscodeField("Enter PIN") { digits, action in
                        self.pin = digits.concat
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    PasscodeField("Re-Enter PIN") { digits, action in
                        self.reEnterPin = digits.concat
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    Button(action: savePIN) {
                        Text("Create PIN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(pin.isEmpty || reEnterPin.isEmpty || pin != reEnterPin ? Color.secondary : Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(pin.isEmpty || reEnterPin.isEmpty || pin != reEnterPin)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding()
            }
        }.navigationBarTitle("Create PIN")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(.blue)
            })
            .interactiveDismissDisabled(true)
    }
    
    func savePIN() {
        if(pin == reEnterPin) {
            var savedEnrollment = GuardianState.loadByEnrollmentId(by: enrollment.identifier);
            savedEnrollment?.enrollmentPIN = pin
            AppDelegate.saveEnrollmentById(enrollment: savedEnrollment!)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CreatePINView_Previews: PreviewProvider {
    @State static var enrollment: GuardianState? = GuardianState.init(
        identifier: "dev_asdad",
        localIdentifier: UIDevice.current.identifierForVendor!.uuidString,
        token: "1231231231231231231323",
        keyTag: "1222",
        otp: OTPParameters(base32Secret: "3SLSWZPQQBB7WBRYDAQZ5J77W5D7I6GU"),
        userEmail: "mdwallick@gmail.com",
        enrollmentTenantDomain: "finserv-demo.guardian.us.auth0.com",
        enrollmentPIN: "0000")
    static var previews: some View {
        CreatePINView(enrollment: enrollment!)
    }
}
