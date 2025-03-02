# Workshop 4 - ZPass Program

## Command Dump

```BASH
# Issuer
export NODEPK=
export NODEVK=
export NODEADDR=

# User
export NODE1PK=
export NODE1VK=
export NODE1ADDR=

export ENDPOINT="https://api.explorer.provable.com/v1"
export PROGRAM="zpass_merkle_kaxxa123.aleo"

snarkos  developer  deploy  ${PROGRAM}  \
    --private-key "${NODEPK}" \
    --path "./build/" \
    --query "${ENDPOINT}" \
    --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
    --priority-fee 1000 \
    --network 1

# at1l992pe6pszskmd3lq8yvm98xjqg7y2mdj5vulhgqv8xrngtgdqpse3e59d
```

Issue zPass (through React App): <BR />
`at1mf3u5kthgr8vc2uyfwmj5d0upfkvylsxhayllvcwd83r867wqcrqku2mhu`

```BASH
export RECORD_ENC=record1qyqsqq5gjelpuf5ekh8j5ushldpa3s59292czzss34z8arepzewwpvq2qgrxjumnw4jhyscqqgpqpkm5hq2fnpe3uylf5f7fjyahsakmsyj0sfd76uhtvlh4xetre3gzevsnx5ul6ap2hs6ku5cw4fwqcc2pnv0en5eguhpzmf877l6qxs9qgun0da6yxqqzqgqwl54267es32ca8ugyety6ajys6j739za7jlhrge677ej9pqpxyy89akmdkdu82qs8g9f737th73frsx3a5spgna5lwc9kzp3kyaz3p3jgemyfgj750en7fye9k063lvhls4lg6sy9t3zrllxw7s5ze4rqk3ql0fc

snarkos developer decrypt \
    --network 1 \
    --view-key ${NODEVK} \
    --ciphertext ${RECORD_ENC}
```

```JSON
{
  owner: aleo1kmzwjeprmskjvhyjtmevq9fkanda57fn0af9fpe7830psw59dvrskmmdaj.private,
  issuer: aleo1kmzwjeprmskjvhyjtmevq9fkanda57fn0af9fpe7830psw59dvrskmmdaj.private,
  root: 5137771540400328188142435007968674669749470665226221384323149250173745868440field.private,
  _nonce: 5100538998793835535445321864875914406914205312844532208095936817532530101348group.public
}
```
