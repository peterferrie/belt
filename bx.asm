;
;  Copyright © 2016 Odzhan, Peter Ferrie. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;
; -----------------------------------------------
; Bel-T block cipher in x86 assembly
;
; size: 520
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32
    
    %ifndef BIN
      global belt_encryptx
      global _belt_encryptx
    %endif
    
struc pushad_t
  _edi dd ?
  _esi dd ?
  _ebp dd ?
  _esp dd ?
  _ebx dd ?
  _edx dd ?
  _ecx dd ?
  _eax dd ?
  .size:
endstruc

%define BELT_ENCRYPT 0
%define BELT_DECRYPT 1

%define t   eax
%define a   ebx
%define b   ecx
%define c   edx
%define d   esi
%define e   ebp
%define key edi

%define G   dword[esp+ 8] ; before call

%define p   dword[esp+ 8]
%define i   dword[esp+12] 
%define j   dword[esp+16]
%define enc dword[esp+20]

belt_encryptx:
_belt_encryptx:
    pushad
    lea    esi, [esp+32+4]
    pushad                   ; allocate 32-bytes for key
    mov    edi, esp
    lodsd
    xchg   ebx, eax          ; ebx=blk
    lodsd
    push   eax               ; save ks
    lodsd
    cdq                      ; edx=0
    ; memcpy (key.v8, (uint8_t*)ks, 32);
    push   32
    pop    ecx
    pop    esi               ; esi=ks
    push   edi
    rep    movsb             ; copy key to local buffer
    pop    edi
    
    push   eax               ; enc
    push   edx               ; j
    push   edx               ; i
    test   eax, eax          ; BELT_ENCRYPT
    je     b_l1
    
    mov    esi, edi
reverse_key:
    lodsd                    ; eax=key[i]
    push   7
    pop    ebp
    sub    ebp, ecx
    xchg   eax, [edi+ebp*4]
    mov    [esi-4], eax
    inc    ecx
    cmp    ecx, 4
    jnz    reverse_key
b_l1:
    mov    esi, ebx
    push   esi               ; save pointer to blk
    lodsd
    xchg   a, eax
    lodsd
    xchg   b, eax
    lodsd
    xchg   c, eax
    lodsd
    xchg   d, eax
    call   b_l2
    ; ------------------------
    pushad
    mov    eax, [esp+32+ 4]
    mov    ebx, [esp+32+20] ; j
    and    ebx, 7
    add    eax, [edi+ebx*4]
    push   4
    pop    ecx
    call   g_l0
    ; sbox
    db 0xB1, 0x94, 0xBA, 0xC8, 0x0A, 0x08, 0xF5, 0x3B,
    db 0x36, 0x6D, 0x00, 0x8E, 0x58, 0x4A, 0x5D, 0xE4,
    db 0x85, 0x04, 0xFA, 0x9D, 0x1B, 0xB6, 0xC7, 0xAC,
    db 0x25, 0x2E, 0x72, 0xC2, 0x02, 0xFD, 0xCE, 0x0D,
    db 0x5B, 0xE3, 0xD6, 0x12, 0x17, 0xB9, 0x61, 0x81,
    db 0xFE, 0x67, 0x86, 0xAD, 0x71, 0x6B, 0x89, 0x0B,
    db 0x5C, 0xB0, 0xC0, 0xFF, 0x33, 0xC3, 0x56, 0xB8,
    db 0x35, 0xC4, 0x05, 0xAE, 0xD8, 0xE0, 0x7F, 0x99,
    db 0xE1, 0x2B, 0xDC, 0x1A, 0xE2, 0x82, 0x57, 0xEC,
    db 0x70, 0x3F, 0xCC, 0xF0, 0x95, 0xEE, 0x8D, 0xF1,
    db 0xC1, 0xAB, 0x76, 0x38, 0x9F, 0xE6, 0x78, 0xCA,
    db 0xF7, 0xC6, 0xF8, 0x60, 0xD5, 0xBB, 0x9C, 0x4F,
    db 0xF3, 0x3C, 0x65, 0x7B, 0x63, 0x7C, 0x30, 0x6A,
    db 0xDD, 0x4E, 0xA7, 0x79, 0x9E, 0xB2, 0x3D, 0x31,
    db 0x3E, 0x98, 0xB5, 0x6E, 0x27, 0xD3, 0xBC, 0xCF,
    db 0x59, 0x1E, 0x18, 0x1F, 0x4C, 0x5A, 0xB7, 0x93,
    db 0xE9, 0xDE, 0xE7, 0x2C, 0x8F, 0x0C, 0x0F, 0xA6,
    db 0x2D, 0xDB, 0x49, 0xF4, 0x6F, 0x73, 0x96, 0x47,
    db 0x06, 0x07, 0x53, 0x16, 0xED, 0x24, 0x7A, 0x37,
    db 0x39, 0xCB, 0xA3, 0x83, 0x03, 0xA9, 0x8B, 0xF6,
    db 0x92, 0xBD, 0x9B, 0x1C, 0xE5, 0xD1, 0x41, 0x01,
    db 0x54, 0x45, 0xFB, 0xC9, 0x5E, 0x4D, 0x0E, 0xF2,
    db 0x68, 0x20, 0x80, 0xAA, 0x22, 0x7D, 0x64, 0x2F,
    db 0x26, 0x87, 0xF9, 0x34, 0x90, 0x40, 0x55, 0x11,
    db 0xBE, 0x32, 0x97, 0x13, 0x43, 0xFC, 0x9A, 0x48,
    db 0xA0, 0x2A, 0x88, 0x5F, 0x19, 0x4B, 0x09, 0xA1,
    db 0x7E, 0xCD, 0xA4, 0xD0, 0x15, 0x44, 0xAF, 0x8C,
    db 0xA5, 0x84, 0x50, 0xBF, 0x66, 0xD2, 0xE8, 0x8A,
    db 0xA2, 0xD7, 0x46, 0x52, 0x42, 0xA8, 0xDF, 0xB3,
    db 0x69, 0x74, 0xC5, 0x51, 0xEB, 0x23, 0x29, 0x21,
    db 0xD4, 0xEF, 0xD9, 0xB4, 0x3A, 0x62, 0x28, 0x75,
    db 0x91, 0x14, 0x10, 0xEA, 0x77, 0x6C, 0xDA, 0x1D
g_l0:
    pop    ebx
g_l1:
    xlatb                    ; u.b[i] = H[u.b[i]];
    ror    eax, 8
    loop   g_l1
    mov    ecx, [esp+32+8]
    rol    eax, cl           ; return ROTL32(u.w, r);
    mov    [esp+_eax], eax
    popad
    inc    dword[esp+20]     ; j++
    retn   2*4
    ; -----------------------
b_l2:
    push   5
    push   a
    call   G   
    xor    b, t            ; b ^= G(a,     key, j+0, 5);
    
    push   21
    push   d
    call   G     
    xor    c, t            ; c ^= G(d,     key, j+1,21);
    
    push   13
    push   b
    call   G       
    sub    a, t            ; a -= G(b,     key, j+2,13);
    
    push   21
    mov    t, b
    add    t, c
    push   t
    call   G               ; e  = G(b + c, key, j+3,21);
    xchg   t, e
    
    mov    t, i            ; t = i + 1;
    inc    t
    
    cmp    dword[esp+4*4], BELT_ENCRYPT
    je     b_l4
    
    push   7                 
    pop    t
    sub    t, i
    inc    t               ; t = (7 - i) + 1;
b_l4:
    xor    e, t            ; e   ^= t;
    add    b, e            ; v.b += e;
    sub    c, e            ; v.c -= e;
    
    push   13
    push   c
    call   G
    add    d, t       ; v.d += G(v.c,     &key, j+4,13);
    
    push   21
    push   a
    call   G
    xor    b, t       ; v.b ^= G(v.a,     &key, j+5,21);
    
    push   5
    push   d
    call   G
    xor    c, t       ; v.c ^= G(v.d,     &key, j+6, 5);
    
    xchg   a, b
    xchg   c, d
    xchg   b, c
    
    cmp    dword[esp+4*4], BELT_ENCRYPT  
    je     b_l5         ; if (enc==BELT_ENCRYPT) 
                        ;     continue;
    xchg   b, c
    xchg   a, d
b_l5:
    inc    i
    cmp    i, 8
    jnz    b_l2
    
    pop    eax
    pop    edi
    push   edi

    xchg   eax, b
    stosd
    xchg   eax, d
    stosd
    xchg   eax, a
    stosd
    xchg   eax, c
    stosd
    
    pop    edi
    cmp    dword[esp+2*4], BELT_ENCRYPT  
    je     b_l6
    
    stosd
    xchg   eax, c
    stosd
    xchg   eax, a
    stosd
    xchg   eax, d
    stosd
b_l6:
    add    esp, pushad_t_size + 3*4  ; release stack
    popad                    ; restore registers
    ret
    
    
    