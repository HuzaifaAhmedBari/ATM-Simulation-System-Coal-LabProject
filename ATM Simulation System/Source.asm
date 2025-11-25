INCLUDE Irvine32.inc

.data
    balance         DWORD   10000
    correctPIN      DWORD   1234
    adminPass       DWORD   9999
    usdRate         DWORD   280
    eurRate         DWORD   300
    sarRate         DWORD   75

    ; ================= STRINGS =================
    mainTitleStr    BYTE    "===== ATM SYSTEM =====",0
    mainMenuStr     BYTE    0Dh,0Ah,"1. Customer Portal",0Dh,0Ah, \
                           "2. Admin Portal",0Dh,0Ah, \
                           "3. Exit",0Dh,0Ah, \
                           "Select Option: ",0

    custMenuStr     BYTE    0Dh,0Ah,"----- CUSTOMER MENU -----",0Dh,0Ah, \
                           "1. View Balance",0Dh,0Ah, \
                           "2. Deposit",0Dh,0Ah, \
                           "3. Withdraw",0Dh,0Ah, \
                           "4. Currency Conversion",0Dh,0Ah, \
                           "5. View Current Exchange Rates",0Dh,0Ah, \
                           "6. Back to Main Menu",0Dh,0Ah, \
                           "Choice: ",0

    adminMenuStr    BYTE    0Dh,0Ah,"----- ADMIN PORTAL -----",0Dh,0Ah, \
                           "1. View Balance",0Dh,0Ah, \
                           "2. Reset Customer PIN",0Dh,0Ah, \
                           "3. Change Exchange Rates",0Dh,0Ah, \
                           "4. Refill ATM Cash",0Dh,0Ah, \
                           "5. View Current Exchange Rates",0Dh,0Ah, \
                           "6. Back to Main Menu",0Dh,0Ah, \
                           "Choice: ",0

    msgConvChoiceStr BYTE "1. Convert Full Balance | 2. Enter Amount : ",0
    msgEnterAmountStr BYTE "Enter amount to convert (PKR): ",0
    msgEnterPINStr   BYTE "Enter Customer PIN: ",0
    msgEnterAdminStr BYTE "Enter Admin Password: ",0
    msgBalanceStr    BYTE "Current Balance (PKR): ",0
    msgDepositStr    BYTE "Enter Deposit Amount (PKR): ",0
    msgWithdrawStr   BYTE "Enter Withdraw Amount (PKR): ",0
    msgNewPINStr     BYTE "Enter new PIN (4 digits): ",0
    msgNewUSDStr     BYTE "Enter new USD rate (PKR per USD): ",0
    msgNewEURStr     BYTE "Enter new EUR rate (PKR per EUR): ",0
    msgNewSARStr     BYTE "Enter new SAR rate (PKR per SAR): ",0
    msgRefillStr     BYTE "Enter refill amount (PKR): ",0
    msgSuccessStr    BYTE "Operation Successful.",0
    msgFailedStr     BYTE "Operation Failed.",0
    msgInsuffStr     BYTE "Insufficient Balance!",0
    msgWrongStr      BYTE "Invalid Password / PIN!",0

    msgBalUSDStr     BYTE "Balance in USD (approx): ",0
    msgBalEURStr     BYTE "Balance in EUR (approx): ",0
    msgBalSARStr     BYTE "Balance in SAR (approx): ",0

    msgRateHeaderStr BYTE "---- Current Exchange Rates ----",0
    msgUSDRateStr    BYTE "USD Rate (PKR per USD): ",0
    msgEURRateStr    BYTE "EUR Rate (PKR per EUR): ",0
    msgSARRateStr    BYTE "SAR Rate (PKR per SAR): ",0

    pinAttempts DWORD 0
    msgRetryLimitStr BYTE "Retry limit reached. Returning to Main Menu.",0
    msgLoginSuccessStr BYTE "Login Successful. Redirecting to Customer Menu...",0

.code
    main PROC

    MainMenu:
        call Clrscr
        mov edx, OFFSET mainTitleStr
        call WriteString
        mov edx, OFFSET mainMenuStr
        call WriteString
        call ReadInt
        cmp eax, 1
        je CustLogin
        cmp eax, 2
        je AdmLogin
        cmp eax, 3
        je ExitProgram
        jmp MainMenu

    ; ---------------- CUSTOMER ----------------

    CustLogin:
        call Clrscr
        mov pinAttempts, 0

    CustPINLoop:
        mov edx, OFFSET msgEnterPINStr
        call WriteString
        call ReadInt
        cmp eax, correctPIN
        je CustLoginSuccess

        inc pinAttempts
        cmp pinAttempts, 3
        jl CustTryAgain

        ; Retry limit reached (NO LOCK)
        mov edx, OFFSET msgRetryLimitStr
        call WriteString
        call CrLf
        mov eax, 1000
        call Delay
        jmp MainMenu

    CustTryAgain:
        mov edx, OFFSET msgWrongStr
        call WriteString
        call CrLf
        jmp CustPINLoop

    CustLoginSuccess:
        mov edx, OFFSET msgLoginSuccessStr
        call WriteString
        call CrLf
        mov eax, 1000       ; 1 second delay
        call Delay
        call Clrscr
        jmp CustMenu

    CustMenu:
        mov edx, OFFSET custMenuStr
        call WriteString
        call ReadInt
        cmp eax, 1
        je CustShowBalance
        cmp eax, 2
        je CustDeposit
        cmp eax, 3
        je CustWithdraw
        cmp eax, 4
        je CustCurrencyMenu
        cmp eax, 5
        je CustViewRates
        cmp eax, 6
        je MainMenu
        jmp CustMenu

    CustShowBalance:
        mov edx, OFFSET msgBalanceStr
        call WriteString
        mov eax, balance
        call WriteDec
        call CrLf
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp CustMenu

    CustDeposit:
        mov edx, OFFSET msgDepositStr
        call WriteString
        call ReadInt
        cmp eax, 0
        jle CustDepositFail
        add balance, eax
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp CustMenu

    CustDepositFail:
        mov edx, OFFSET msgFailedStr
        call WriteString
        call CrLf
        jmp CustMenu

    CustWithdraw:
        mov edx, OFFSET msgWithdrawStr
        call WriteString
        call ReadInt
        mov ebx, eax
        cmp ebx, 0
        jle CustWithdrawFail
        mov eax, balance
        cmp eax, ebx
        jb CustInsufficient
        sub balance, ebx
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp CustMenu

    CustWithdrawFail:
        mov edx, OFFSET msgFailedStr
        call WriteString
        call CrLf
        jmp CustMenu

    CustInsufficient:
        mov edx, OFFSET msgInsuffStr
        call WriteString
        call CrLf
        jmp CustMenu

    CustCurrencyMenu:
        mov edx, OFFSET msgConvChoiceStr
        call WriteString
        call ReadInt

        cmp eax, 1
        je ConvertFullBalance
        cmp eax, 2
        je ConvertCustomAmount
        jmp CustMenu

    ConvertFullBalance:
        mov eax, balance
        jmp PerformConversion

        ConvertCustomAmount:
        mov edx, OFFSET msgEnterAmountStr
        call WriteString
        call ReadInt
        cmp eax, 0
        jle CustMenu

    PerformConversion:
        ; ---- USD ----
        mov edx, OFFSET msgBalUSDStr
        call WriteString
        mov ebx, usdRate
        xor edx, edx
        div ebx
        call WriteDec
        call CrLf

        ; ---- EUR ----
        mov eax, balance
        mov edx, OFFSET msgBalEURStr
        call WriteString
        mov ebx, eurRate
        xor edx, edx
        div ebx
        call WriteDec
        call CrLf

        ; ---- SAR ----
        mov eax, balance
        mov edx, OFFSET msgBalSARStr
        call WriteString
        mov ebx, sarRate
        xor edx, edx
        div ebx
        call WriteDec
        call CrLf

        jmp CustMenu

    CustViewRates:
        mov edx, OFFSET msgRateHeaderStr
        call WriteString
        call CrLf

        mov edx, OFFSET msgUSDRateStr
        call WriteString
        mov eax, usdRate
        call WriteDec
        call CrLf

        mov edx, OFFSET msgEURRateStr
        call WriteString
        mov eax, eurRate
        call WriteDec
        call CrLf

        mov edx, OFFSET msgSARRateStr
        call WriteString
        mov eax, sarRate
        call WriteDec
        call CrLf

        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp CustMenu


    ; ---------------- ADMIN ----------------

    AdmLogin:
        call Clrscr
        mov edx, OFFSET msgEnterAdminStr
        call WriteString
        call ReadInt
        cmp eax, adminPass
        jne AdmLoginFail
        jmp AdmMenu

    AdmLoginFail:
        mov edx, OFFSET msgWrongStr
        call WriteString
        call CrLf
        mov eax, 500
        call Delay
        jmp MainMenu

    AdmMenu:
        mov edx, OFFSET adminMenuStr
        call WriteString
        call ReadInt
        cmp eax, 1
        je AdmViewBalance
        cmp eax, 2
        je AdmResetPIN
        cmp eax, 3
        je AdmChangeRates
        cmp eax, 4
        je AdmRefill
        cmp eax, 5
        je AdmViewRates
        cmp eax, 6
        je MainMenu
        jmp AdmMenu

    AdmViewBalance:
        mov edx, OFFSET msgBalanceStr
        call WriteString
        mov eax, balance
        call WriteDec
        call CrLf
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp AdmMenu

    AdmResetPIN:
        mov edx, OFFSET msgNewPINStr
        call WriteString
        call ReadInt
        cmp eax, 1000
        jb AdmResetPINFail
        mov correctPIN, eax
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp AdmMenu

    AdmResetPINFail:
        mov edx, OFFSET msgFailedStr
        call WriteString
        call CrLf
        jmp AdmMenu

    AdmChangeRates:
        mov edx, OFFSET msgNewUSDStr
        call WriteString
        call ReadInt
        mov usdRate, eax
        mov edx, OFFSET msgNewEURStr
        call WriteString
        call ReadInt
        mov eurRate, eax
        mov edx, OFFSET msgNewSARStr
        call WriteString
        call ReadInt
        mov sarRate, eax
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp AdmMenu

    AdmRefill:
        mov edx, OFFSET msgRefillStr
        call WriteString
        call ReadInt
        add balance, eax
        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp AdmMenu

    ; -------- NEW FEATURE --------
    AdmViewRates:
        mov edx, OFFSET msgRateHeaderStr
        call WriteString
        call CrLf

        mov edx, OFFSET msgUSDRateStr
        call WriteString
        mov eax, usdRate
        call WriteDec
        call CrLf

        mov edx, OFFSET msgEURRateStr
        call WriteString
        mov eax, eurRate
        call WriteDec
        call CrLf

        mov edx, OFFSET msgSARRateStr
        call WriteString
        mov eax, sarRate
        call WriteDec
        call CrLf

        mov edx, OFFSET msgSuccessStr
        call WriteString
        call CrLf
        jmp AdmMenu

    ExitProgram:
        exit

    main ENDP
END main