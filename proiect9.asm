.386
.model flat, stdcall


includelib msvcrt.lib
extern exit: proc
extern fopen:proc
extern fprintf: proc
extern fread:proc
extern scanf:proc
extern printf:proc
extern fclose:proc
extern fscanf: proc
extern strcpy:proc
extern memmove:proc
extern strlen:proc
extern strstr:proc
extern fgets:proc
extern fseek:proc

public start

.data
format_fisier db "%s",0
fisier db 100 dup(0)
fisier_aux db "fisier_aux.txt",0
format_citire db "r",0
format_scriere db "w",0 
format_char db "%c",0
char db 0
buffer db 0
cc db 0
rpl1 db 20 dup(0)
rpl2 db 20 dup(0)
string db 100 dup(0)
msg1 db "Introduceti calea fisierului: ",10,13,0
msg2 db "Introduceti caracterul: ",10,13,0
msg3 db "introduceti secventele de inlocuit :",10,13,0
msg_c db "Introduceti o comanda: ",10,13,0
f db "%d ",0
endline db 10,13,0
var dd 0
ct dd -1
comanda db 100 dup(0)
format_sir db "%s",0
adresa dd 0
adresa2 dd 0
lg1 dd 0
lg2 dd 0
instructiune db 100 dup(0)
msg_fis db "Nu s-a putut deschide fisierul.",0
findc db "findc",0
replace db "replace",0
findtxt db "find",0
toUppertxt db "toUpper",0
toLowertxt db "toLower",0
toSentencetxt db "toSentence",0
listtxt db "list",0
lg_comada dd 0
exittxt db"exit",0
err db "Comanda incorecta!",10,13,0
.code


;cautare de cate ori apare un caracter adaugat de la tastatura
findcp proc
	push ebp
	mov ebp, esp
	
	xor edi,edi
	xor ebx,ebx
	
	
	mov bl,[ebp+12]  ; in bl se afla caracterul cautat
	
	mov esi, [ebp+8]
	
	;citire din fisier caracter cu caracter
	push esi
	push 1
	push 1
	push offset cc
bucla_citire:
	call fread
	test eax,eax    ; aici testestezi daca ai ajuns la capatul fisierului
	jz inchidere_fisier
	xor eax, eax  ;stergerea continutului din eax
	
	mov al,cc ; in eax se pastreaza litera citita
	
	cmp al,bl ; se verifica daca litera citita este cea cautata , daca da se incrementeaza edi(contorul de aparitii)
	jne next
	inc edi
	next:
jmp bucla_citire ; se citeste urmatoarea litera
	
	inchidere_fisier: ; inchiderea fisierului si revenirea din procedura
	add esp, 16
	
	push esi
	call fclose
	add esp,4
	
	push edi      ; afisarea numarului de aparitii
	push offset f
	call printf
	add esp, 8
	
	mov cc,0
	
	mov esp, ebp
	pop ebp
	ret 8
findcp endp


;cautare pozitiile la care apare un cuvant
find proc
	push ebp
	mov ebp, esp
	
	sub esp,4
	
	push [ebp+8]  ;cuvantul cautat
	call strlen
	add esp,4
	mov [ebp-4],eax ;lungimea cuvantului
nu:
	add ct,1        ; ct = pozitia unde e gasit
	ok:
	mov esi,[ebp+8] ;cuvantul cautat
	mov edi,[ebp-4] ;lungimea cuvantului
	;mov eax,ct
lp:
	push [ebp+12]  
	push 1
	push 1
	push offset char
	call fread     ;citire litera cu litera
	add esp,16
	
	xor ebx,ebx
	
	mov bl,char
	
	cmp eax,0  ;verificare sfarsit fisier
	jle inchidere_fisier

	verif:
	
	mov bh,byte ptr[esi]
	
	cmp bl,byte ptr[esi] ;compar litera citita cu litera la care ne aflam in sirul cautat
	je cont				 ;daca e egal se continua cu decrementarea lungimii si incrementarea pointerului la esi(cuvant)
	cmp edi,[ebp-4]
	je nu                ;se incrementeaza pozitia de gasire
	mov esi,[ebp+8]
	mov edi,[ebp-4]
	jmp verif
	cont:
	inc esi
	dec edi
	test edi,edi
	jnz lp ;continuarea cautarii
	
	
	;niste verificari care nu mai stiu exact ce fac,
	;fa niste debugging ca iti dai seama de acolo
	xor ecx,ecx
	mov ecx,[ebp-4]
	cmp ecx,1
	je a
	add ct,1
	a:
	
	xor eax,eax
	mov eax,ct
	;add ct,1
	cmp eax,1
	jne b
	mov eax,0
	b:
	
	push eax
	push offset f
	call printf
	add esp,8
	
	xor eax,eax
	mov eax,ct
	add eax,[ebp-4] ;se adauga la pozitie lungimea cuvantului gasit
	mov ct,eax
	sub ct,1
jmp ok	
	
inchidere_fisier:
	
	push [ebp+12]
	call fclose
	add esp,4
	
	mov ct,0
	mov char,0
	
	mov esp, ebp
	pop ebp
	ret 8
find endp


;se rescrie tot fisierul cu litera mare
toUpper proc
	push ebp
	mov ebp, esp
	
	push offset format_scriere ;folosesc un fisier aux pentru rescrierea fisierului
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2, eax
	
	push offset char
	push offset format_char
	push [ebp+8]
lp:
	call fscanf ;citire litera cu litera
	
	cmp eax,0   ;identificator deschidere fisier
	jle inchidere_fisier
	
	xor ebx,ebx
	mov bl, char
	
	;verific daca sunt litere mici (intre 97 si 122) prin codul ascii
	cmp ebx, 97  
	jb mare
	
	cmp ebx,122
	ja mare
	
	sub ebx,32   ;se scade 32 din literele mici pentru a deveni mari
	mare:       ;daca sunt deja litere mari se scriu direct in fisierul auxiliar
	push ebx
	push offset format_char
	push adresa2
	call fprintf
	add esp,12
jmp lp
	
	
	
inchidere_fisier:
	add esp,12
	push [ebp+8]
	call fclose
	add esp,4
	
	
	push adresa2
	call fclose
	add esp,4
	
	push offset format_scriere
	push offset fisier
	call fopen
	add esp,8
	mov adresa,eax
	
	push offset format_citire
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2,eax
	
	xor ebx,ebx
	
	;se scrie litera cu litera din fisierul auxiliar in cel original
	push adresa2
	push 1
	push 1
	push offset char
schimb:
	call fread
	
	test eax,eax
	jz gata
	
	mov bl,char
	
	push ebx
	push offset format_char
	push adresa
	call fprintf
	add esp,12
jmp schimb	
gata:
	add esp,16
	
	push adresa2
	call fclose
	add esp,4
	
	push adresa
	call fclose
	add esp,4
	
	mov char,0
	
	mov esp, ebp
	pop ebp
	ret 4
toUpper endp


;acelasi lucru pentru toLower, doar ca se adauga 32 si literele mari se afla intre 65 si 90
toLower proc
	push ebp
	mov ebp, esp
	
	push offset format_scriere
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2, eax
	
	push offset char
	push offset format_char
	push [ebp+8]
lp:
	call fscanf
	
	cmp eax,0
	jle inchidere_fisier
	
	xor ebx,ebx
	mov bl, char
	
	cmp ebx, 65
	jb mic
	
	cmp ebx,90
	ja mic
	
	add ebx,32
	mic:
	push ebx
	push offset format_char
	push adresa2
	call fprintf
	add esp,12
jmp lp
	
	
	
inchidere_fisier:
	add esp,12
	push [ebp+8]
	call fclose
	add esp,4
	
	push adresa2
	call fclose
	add esp,4
	
	push offset format_scriere
	push offset fisier
	call fopen
	add esp,8
	mov adresa,eax
	
	push offset format_citire
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2,eax
	
	xor ebx,ebx
	
	push adresa2
	push 1
	push 1
	push offset char
schimb:
	call fread
	
	test eax,eax
	jz gata
	
	mov bl,char
	
	push ebx
	push offset format_char
	push adresa
	call fprintf
	add esp,12
jmp schimb	
gata:
	add esp,16
	
	push adresa2
	call fclose
	add esp,4
	
	push adresa
	call fclose
	add esp,4
	
	mov char,0
	
	mov esp, ebp
	pop ebp
	ret 4
toLower endp




;scrie cu litera mare dupa punct
toSentence proc
	push ebp
	mov ebp, esp
	
	push offset format_scriere
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2, eax
	
	sen:	
			; verifica daca litera citita din fisier este mica si o transforma in litera mare
			push offset char
			push offset format_char
			push [ebp+8]
			call fscanf
			add esp,12
			
			test eax,eax
			jz inchidere_fisier
			
			xor ebx,ebx
			mov bl,char
			
			cmp ebx, 97
			jb con
	
			cmp ebx,122
			ja afi
	
			sub ebx,32
con:
	; verifica daca litera citita din fisier este mare => o ignora
	cmp ebx,90
	ja sen
	
	cmp ebx,65
	jb sen
afi:	
	push ebx
	push offset format_char
	push adresa2
	call fprintf             ;scrie in fisierul auxiliar
	add esp,12
	
	push offset char
	push offset format_char
	push [ebp+8]
lp:
	call fscanf
	
	cmp eax,0
	jle inchidere_fisier
	
	xor ebx,ebx
	mov bl,char
	
	;verifica daca caracterul citit este semn de punctuatie
	cmp bl, 46
	je sentence
	cmp bl,63
	je sentence
	cmp bl,33
	jne afis
		sentence:
			;daca e semn de punctuatie de afiseaza in fisierul auxiliar si se citeste urmatoarea litera
			push ebx
			push offset format_char
			push adresa2
			call fprintf
			add esp,12
			
			push offset char
			push offset format_char
			push [ebp+8]
			call fscanf
			add esp,12
			
			test eax,eax
			jz inchidere_fisier
			
			xor ebx,ebx
			mov bl,char
			
			;cond litera mare
			cmp ebx, 97
			jb cond
			
			;cond alte caractere => se afiseaza
			cmp ebx,122
			ja afis
			
			;trasnformare din litera mica in mare
			sub ebx,32
cond:
	cmp ebx,90
	ja sentence
	
	cmp ebx,65
	jb sentence
afis:	
	push ebx
	push offset format_char
	push adresa2
	call fprintf
	add esp,12
jmp lp ;se continua citirea din fisier
	
inchidere_fisier:
	add esp,12
	push [ebp+8]
	call fclose
	add esp,4
	
	push adresa2
	call fclose
	add esp,4
	
	push offset format_scriere
	push offset fisier
	call fopen
	add esp,8
	mov adresa,eax
	
	push offset format_citire
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2,eax
	
	xor ebx,ebx
	
	push adresa2
	push 1
	push 1
	push offset char
schimb:
	;se copiaza fisierul auxiliar (cel editat) in cel original
	call fread
	
	test eax,eax
	jz gata
	
	mov bl,char
	
	push ebx
	push offset format_char
	push adresa
	call fprintf
	add esp,12
jmp schimb	
gata:
	add esp,16
	
	push adresa2
	call fclose
	add esp,4
	
	push adresa
	call fclose
	add esp,4
	
	mov char,0

	mov esp, ebp
	pop ebp
	ret 4
toSentence endp


;face replace la toate aparitiile unui cuvant cu altul
replacep proc
	push ebp
	mov ebp, esp
	
	;ebp+16 adresa
	;ebp+12 rpl1
	;ebp+8 rpl2
	
	sub esp,8
	
	push offset format_scriere
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2,eax
	
	push [ebp+12]  ;cuvanul de inlocuit
	call strlen
	add esp,4
	mov [ebp-4],eax  ;lungimea cuvantului
	
nu: 
	mov esi,[ebp+12] ;cuvanul de inlocuit
	mov edi,[ebp-4] ;lungimea cuvantului
	;mov eax,ct
lp:
	push [ebp+16]
	push 1
	push 1
	push offset char
	call fread        ;se citeste litera cu litera
	add esp,16
	
	xor ebx,ebx
	
	mov bl,char      ;se memoreaza litera in bl
	
	cmp eax,0
	jle inchidere_fisier
	
	verif:
	
	
	cmp bl,byte ptr[esi]  ;litera la care se afla pointerul catre cuvantul cautat cu litera citita
	je cont
	cmp edi,[ebp-4]   ;comparare contorul din procedura cu lungimea cuvantului (verificare daca cuvantul nu a fost gasit)
	jz afis
	xor ecx,ecx
	mov ecx,[ebp-4]
	dec ecx
	cmp edi,ecx
	je modif
	xor ecx,ecx
	mov ecx,edi
	sub ecx,[ebp-4]
	sub ecx,1
	
	push 1
	push ecx
	push [ebp+16]
	call fseek
	add esp,12
	
	push [ebp+16]
	push 1
	push 1
	push offset char
	call fread
	add esp,16
	xor ebx,ebx
	
	mov bl,char
	
	mov esi,[ebp+12]
	mov edi,[ebp-4]
	
	afis:
	push ebx
	push offset format_char
	push adresa2
	call fprintf
	add esp,12
	jmp nu
	
	modif:
	push [ebp-8]
	push offset format_char
	push adresa2
	call fprintf
	add esp,12
	mov esi,[ebp+12]
	mov edi,[ebp-4]
	jmp verif
	
	push ebx
	push offset format_char
	push adresa2
	call fprintf
	add esp,12
	
	cont:
	mov [ebp-8],ebx
	inc esi
	dec edi
	test edi,edi ;verificare daca am citit un numar de litere egal cu cuvantul
	jnz lp
	
	push [ebp+8] 
	push offset format_sir
	push adresa2
	call fprintf
	add esp,12
jmp nu
inchidere_fisier:
	
	push [ebp+16]
	call fclose
	add esp,4
	
	push adresa2
	call fclose
	add esp,4
	
	push offset format_scriere
	push offset fisier
	call fopen
	add esp,8
	mov adresa,eax
	
	push offset format_citire
	push offset fisier_aux
	call fopen
	add esp,8
	mov adresa2,eax
	
	xor ebx,ebx
	
	push adresa2
	push 1
	push 1
	push offset char
schimb:
	call fread
	
	test eax,eax
	jz gata
	
	mov bl,char
	
	push ebx
	push offset format_char
	push adresa
	call fprintf
	add esp,12
jmp schimb	
gata:
	add esp,16
	
	push adresa2
	call fclose
	add esp,4
	
	push adresa
	call fclose
	add esp,4
	
	mov esp, ebp
	pop ebp
	ret 12
replacep endp



;afiseaza continutul fisierului
list proc
	push ebp
	mov ebp, esp
	
	push [ebp+8]
	push 1
	push 1
	push offset char
lp:
	call fread
	
	test eax,eax
	jz inchidere_fisier
	
	xor ebx,ebx
	mov bl,char
	
	push ebx
	push offset format_char
	call printf
	add esp,8
jmp lp
	
inchidere_fisier:
	add esp,16
	
	push [ebp+8]
	call fclose
	add esp,4
	
	mov char,0

	mov esp, ebp
	pop ebp
	ret 4
list endp



start:
inceput:	
	push offset msg1
	call printf
	add esp,4
	
	push offset fisier
	push offset format_sir
	call scanf
	add esp,8

lp:	
	
	push offset format_citire
	push offset fisier
	call fopen
	add esp,8
	
	test eax,eax
	jz fis

	mov adresa,eax
	
	push offset endline
	call printf
	add esp,4
	
	push offset msg_c
	call printf
	add esp,4
	
	;se citeste comanda si se compara cu stringurile comenzilor existeste si se apeleaza procedurile
	push offset comanda
	push offset format_sir
	call scanf
	add esp,8
	
	push offset comanda
	call strlen
	add esp,4
	
	mov lg_comada,eax
	
	cmp lg_comada,4
	je find_et
	;;;;;;;;;;;;
	
	;se verifica daca comanda adaugata e findc
	lea esi,comanda
	lea edi,findc
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz find_et
	
	push offset buffer
	push offset format_char
	call scanf
	add esp,8
	
	push offset char
	push offset format_char
	call scanf
	add esp,8
	
	xor ebx,ebx
	mov bl,char
	
	;apelare findc
	push ebx
	push adresa
	call findcp
	
	push offset endline
	call printf
	add esp,4
	
	jmp lp ;urmatoarea comanda
;;;;;;;;;;;
find_et: 
	;se compara daca comanda este find
	lea esi,comanda
	lea edi,findtxt
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz up
	
	push offset buffer
	push offset format_char
	call scanf
	add esp,8
	
	push offset string
	push offset format_sir
	call scanf
	add esp,8
	
	push adresa
	push offset string
	call find
	
	push offset endline
	call printf
	add esp,4
	
	jmp lp
;;;;;;;;;;;;;
up:
	;se compara daca comanda este toUpper
	lea esi,comanda
	lea edi,toUppertxt
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz lo
	
	push adresa
	call toUpper
	
	push offset endline
	call printf
	add esp,4
	
	jmp lp
;;;;;;;;;;;;
lo:
	;se compara daca comanda este toLower
	lea esi,comanda
	lea edi,toLowertxt
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz prop
	
	push adresa
	call toLower
	
	push offset endline
	call printf
	add esp,4
	
	jmp lp
;;;;;;;;;;;;
prop:
	;se compara daca comanda este toSentence
	lea esi,comanda
	lea edi,toSentencetxt
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz repl
	
	push adresa
	call toSentence
	
	push offset endline
	call printf
	add esp,4
	
	jmp lp
;;;;;;;;;;;
repl:
	;se compara daca comanda este replace
	lea esi,comanda
	lea edi,replace
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz list_et

	push offset msg3
	call printf
	add esp,4
	
	push offset rpl1
	push offset format_fisier
	call scanf
	add esp,8
	
	push offset rpl2
	push offset format_fisier
	call scanf
	add esp,8
	
	
	push adresa
	push offset rpl1
	push offset rpl2
	call replacep
	
	push offset endline
	call printf
	add esp,4
	
	jmp lp
	
;;;;;;;;;;;;;;;;;;;
list_et:
	;se compara daca comanda este list
	lea esi,comanda
	lea edi,listtxt
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz exit_lb
	
	push adresa
	call list
	
	push offset endline
	call printf
	add esp,4
	jmp lp
fis:

	push offset msg_fis
	call printf
	add esp,4
	
	jmp inceput
	

exit_lb:
	;se compara daca comanda este exit si se termina programul
	lea esi,comanda
	lea edi,exittxt
	mov ecx,lg_comada
	repe cmpsb
	test ecx,ecx
	jnz endd

	push 0
	call exit
endd:
	;se afiseaza un mesaj de eroare (comanda nu exista) si se cere reintroducerea acesteia
	push offset err
	call printf
	add esp,4
	
	jmp lp
	push 0
	call exit
end start