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

