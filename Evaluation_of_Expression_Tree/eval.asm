%include "io.inc"

extern getAST
extern freeAST

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text

global main



atoi:
    enter 0,0
    push edx
    push ecx
    mov eax, 0
    mov esi, [EBP + 8]
    .top:
    movzx ecx, byte [esi] ; get a character
;    cmp ecx, 0
    cmp ecx, "-"
    je negativ
;    jne atoi
    inc esi ; ready for next one
    cmp ecx, '0' ; valid?
    jb .done1
    cmp ecx, '9'
    ja .done1
    
    sub ecx, '0' ; "convert" character to number
    imul eax, 10 ; multiply "result so far" by ten
    add eax, ecx 
    jmp .top
    
    .done1:
    leave 
    ret
    
    negativ:
    .top1:
    movzx ecx, byte [esi + 1] ; get a character
    inc esi ; ready for next one
    cmp ecx, '0' ; valid?
    jb .done2
    cmp ecx, '9'
    ja .done2
    sub ecx, '0' ; "convert" character to number
    imul eax, 10 ; multiply "result so far" by ten
    add eax, ecx 
    jmp .top1
    
    pop ecx
    pop edx
    

    .done2:
    imul eax, -1

    leave 
    ret

recursivitate:
    
    enter 0,0
    mov ebx, [EBP + 8]
    mov ecx, [ebx + 4]
    
    ;daca are cel putin  un copil merge in operatie
    cmp ecx, 0
    jne operatie
    mov ebx, [EBP + 8]
    mov ecx, [ebx + 8]
    cmp ecx, 0
    jne operatie
    
    ;daca e numar
    push DWORD[ebx]
    call atoi
    mov ebx, [EBP + 8]
     
    leave
    ret
    
operatie:
    mov ebx, [EBP + 8] ; nodul curent
    mov ecx, [ebx + 4] ; fiul stang
    
    push ecx
    call recursivitate
    mov ebx, [EBP + 8]
    mov edx, eax ; retinem in edx valoarea din stanga
    mov ecx, [ebx + 8] ; fiul drept
    push edx
    push ecx
    call recursivitate ; retinem in eax valoarea din dreapta
    pop edx
    pop edx
    
    mov ebx, [EBP + 8]
    mov ebx, [ebx + 0]
    mov ebx, [ebx]
    cmp ebx, "+"
    jz adunare
    cmp ebx, "*"
    jz inmultire
    cmp ebx, "-"
    jz scadere
    cmp ebx, "/"
    jz impartire

    adunare:

        add eax, edx 
        leave
        ret

    scadere:
        sub edx, eax
        mov eax, edx
        leave 
        ret
                        
    inmultire:
        imul eax, edx
        leave 
        ret
       
    impartire:
        mov ebx, eax
        push edx
        mov eax, edx
        cdq
        idiv ebx
        pop edx
        leave 
        ret

main:
    mov ebp, esp; for correct debugging
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    push DWORD[root]
    call recursivitate
    PRINT_DEC 4, eax

    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret