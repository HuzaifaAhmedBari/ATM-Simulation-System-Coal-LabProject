; Fixed: removed label/variable name collisions (all data labels end with 'Str')
INCLUDE Irvine32.inc

.data
; ================= DATA (no names collide with code labels) =================
balance         DWORD   10000
correctPIN      DWORD   1234
adminPass       DWORD   9999

usdRate         DWORD   280
eurRate         DWORD   300
sarRate         DWORD   75

; ================= STRINGS (all end with Str) =================
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
                       "5. Back to Main Menu",0Dh,0Ah, \
                       "Choice: ",0

adminMenuStr    BYTE    0Dh,0Ah,"----- ADMIN PORTAL -----",0Dh,0Ah, \
                       "1. View Balance",0Dh,0Ah, \
                       "2. Reset Customer PIN",0Dh,0Ah, \
                       "3. Change Exchange Rates",0Dh,0Ah, \
                       "4. Refill ATM Cash",0Dh,0Ah, \
                       "5. Back to Main Menu",0Dh,0Ah, \
                       "Choice: ",0

msgEnterPINStr  BYTE    "Enter Customer PIN: ",0
msgEnterAdminStr BYTE   "Enter Admin Password: ",0
msgBalanceStr   BYTE    "Current Balance (PKR): ",0
msgDepositStr   BYTE    "Enter Deposit Amount (PKR): ",0
msgWithdrawStr  BYTE    "Enter Withdraw Amount (PKR): ",0

msgNewPINStr    BYTE    "Enter new PIN (4 digits): ",0
msgNewUSDStr    BYTE    "Enter new USD rate (PKR per USD): ",0
msgNewEURStr    BYTE    "Enter new EUR rate (PKR per EUR): ",0
msgNewSARStr    BYTE    "Enter new SAR rate (PKR per SAR): ",0
msgRefillStr    BYTE    "Enter refill amount (PKR): ",0

msgSuccessStr   BYTE    "Operation Successful.",0
msgFailedStr    BYTE    "Operation Failed.",0
msgInsuffStr    BYTE    "Insufficient Balance!",0
msgWrongStr     BYTE    "Invalid Password / PIN!",0

; Simple labels for currency output
msgBalUSDStr    BYTE    "Balance in USD (approx): ",0
msgBalEURStr    BYTE    "Balance in EUR (approx): ",0
msgBalSARStr    BYTE    "Balance in SAR (approx): ",0

.code
main PROC

; ----------------- MAIN MENU (entry) -----------------
MainMenu:
    call Clrscr
    mov edx, OFFSET mainTitleStr
    call WriteString

    mov edx, OFFSET mainMenuStr
    call WriteString

    call ReadInt                   ; EAX = main choice
    cmp eax, 1
    je CustLogin
    cmp eax, 2
    je AdmLogin
    cmp eax, 3
    je ExitProgram
    jmp MainMenu

; ----------------- CUSTOMER FLOW -----------------
CustLogin:
    ; clear screen only when switching interface (Main -> Customer)
    call Clrscr
    mov edx, OFFSET msgEnterPINStr
    call WriteString
    call ReadInt
    cmp eax, correctPIN
    jne CustLoginFail
    jmp CustMenu

CustLoginFail:
    mov edx, OFFSET msgWrongStr
    call WriteString
    call CrLf

    ; wait 1 second (1000 ms)
    mov eax, 500        ; 1 second
    call Delay

    jmp MainMenu      ; go straight back, no repeat


CustMenu:
    ; do NOT clear screen here; we stay on the same interface
    mov edx, OFFSET custMenuStr
    call WriteString
    call ReadInt                     ; EAX = customer choice

    cmp eax, 1
    je CustShowBalance
    cmp eax, 2
    je CustDeposit
    cmp eax, 3
    je CustWithdraw
    cmp eax, 4
    je CustCurrencyMenu
    cmp eax, 5
    je MainMenu                       ; switching interface -> clear happens at target
    jmp CustMenu

CustShowBalance:
    mov edx, OFFSET msgBalanceStr
    call WriteString
    mov eax, balance
    call WriteDec
    call CrLf
    ; show success-ish line to make action apparent
    mov edx, OFFSET msgSuccessStr
    call WriteString
    call CrLf
    jmp CustMenu

CustDeposit:
    mov edx, OFFSET msgDepositStr
    call WriteString
    call ReadInt                       ; EAX = deposit amount
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
    call ReadInt                       ; EAX = withdraw amount
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

; Currency submenu (keeps same screen, no Clrscr)
CustCurrencyMenu:
    ; Show options inline (simple)
    mov edx, OFFSET msgBalUSDStr
    call WriteString
    mov eax, balance
    mov ebx, usdRate
    xor edx, edx
    div ebx             ; EAX = balance / usdRate
    call WriteDec
    call CrLf

    mov edx, OFFSET msgBalEURStr
    call WriteString
    mov eax, balance
    mov ebx, eurRate
    xor edx, edx
    div ebx
    call WriteDec
    call CrLf

    mov edx, OFFSET msgBalSARStr
    call WriteString
    mov eax, balance
    mov ebx, sarRate
    xor edx, edx
    div ebx
    call WriteDec
    call CrLf

    mov edx, OFFSET msgSuccessStr
    call WriteString
    call CrLf
    jmp CustMenu

; ----------------- ADMIN FLOW -----------------
AdmLogin:
    ; clear screen only when switching interface (Main -> Admin)
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

    mov eax, 500        ; 1 second
    call Delay

    jmp MainMenu ; go straight back, no repeat


AdmMenu:
    mov edx, OFFSET adminMenuStr
    call WriteString
    call ReadInt                     ; EAX = admin choice

    cmp eax, 1
    je AdmViewBalance
    cmp eax, 2
    je AdmResetPIN
    cmp eax, 3
    je AdmChangeRates
    cmp eax, 4
    je AdmRefill
    cmp eax, 5
    je MainMenu                       ; switching interface
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
    cmp eax, 1000                      ; simple check: 4 digits minimum
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
    cmp eax, 1
    jb AdmChangeRatesFail
    mov usdRate, eax

    mov edx, OFFSET msgNewEURStr
    call WriteString
    call ReadInt
    cmp eax, 1
    jb AdmChangeRatesFail
    mov eurRate, eax

    mov edx, OFFSET msgNewSARStr
    call WriteString
    call ReadInt
    cmp eax, 1
    jb AdmChangeRatesFail
    mov sarRate, eax

    mov edx, OFFSET msgSuccessStr
    call WriteString
    call CrLf
    jmp AdmMenu

AdmChangeRatesFail:
    mov edx, OFFSET msgFailedStr
    call WriteString
    call CrLf
    jmp AdmMenu

AdmRefill:
    mov edx, OFFSET msgRefillStr
    call WriteString
    call ReadInt
    cmp eax, 0
    jle AdmRefillFail
    add balance, eax
    mov edx, OFFSET msgSuccessStr
    call WriteString
    call CrLf
    jmp AdmMenu

AdmRefillFail:
    mov edx, OFFSET msgFailedStr
    call WriteString
    call CrLf
    jmp AdmMenu

; ----------------- EXIT -----------------
ExitProgram:
    exit

main ENDP
END main