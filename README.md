

## Initialize a Token
This command initializes a cryptographic token with a given label and sets the Security Officer (SO) and user PINs.
```
pkcs11-tool --init-token --label "MyToken" --so-pin "your_SO_PIN" --pin "your_user_PIN"
```