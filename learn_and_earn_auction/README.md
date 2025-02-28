# Auction Command Dump

```BASH
# AUCTIONEER
export NODEPK=
export NODEVK=
export NODEADDR=

# Bidder
export NODE1PK=
export NODE1VK=
export NODE1ADDR=

export ENDPOINT="https://api.explorer.provable.com/v1"

leo account sign \
--private-key "${NODEPK}" \
--message "true"

# sign14jr3g55sa3w7q2v2fn94f3l7rz4g5s04gggz6j8g2q79snlzp5qdzny2s94nwta984xkjwkt3vpd57fzc07lg7htp8hz46545npavq9affm89ralg852j7t36963yvy6vzxfrpfwlzuey8l4uz2uzv49zylka35uxllr6vasemkjy4am6h45htredkklh7gpzrjsvmvk0ylsy7azmsp

snarkos  developer  deploy  learn_and_earn_auction_kaxxa123.aleo  \
    --private-key "${NODEPK}" \
    --path "./build/" \
    --query "${ENDPOINT}" \
    --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
    --priority-fee 10000 \
    --network 1

# at1mdy5gghnk4eq878pfdx3af6n4m5aym8y7gtqage6qexhq6n8gg8sdks4n7
# https://api.explorer.provable.com/v1/testnet/transaction/at1mdy5gghnk4eq878pfdx3af6n4m5aym8y7gtqage6qexhq6n8gg8sdks4n7
# https://api.explorer.provable.com/v1/testnet/program/learn_and_earn_auction_kaxxa123.aleo

# NODE1 Submits bid
snarkos  developer  execute  learn_and_earn_auction_kaxxa123.aleo  place_bid  \
    ${NODE1ADDR} 1234u64   \
    --private-key "${NODE1PK}"  \
    --query "${ENDPOINT}" \
    --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
    --priority-fee 10000 \
    --network 1
# at1wyfu5n4ennjcn7xn053epgaefykexcjkz4g2l0p8j6gph6vqvsfqfzklkh

export RECORD_ENC="record1qyqsqpzsph9y8wg7jsjqr6gs386xezq4294m648nw8tslrwle2fpt7gqqvrxy6tyv3jhyscqqgpqpeam59fmhuu4s5mdce233nqzkc3r05t6l5j0x4w058uv08tdyhcq7tp7cwxdg09uegc3zsma64ktt22kznuxfr7rgty7qcpwzvmk6sysvctdda6kuaprqqpqzqzq0wcm9agp2rx6jjq7cys2e5lmytufhm0xvxd44g9td2hsrr4sqcykju6lwa5kumn9wg3sqqspqqahepkawhtv3w8996nsmpys9v8hztx0fvzulgq63cpzjkf8lz6sgmgg7cjz6vht436g65k73ncz3d5ug2sftf9w37k26szkjdwpq3cr7tetfr"

aleo_decrypt record --vk ${NODEVK} --cipher ${RECORD_ENC}

# {
#   owner: aleo1kmzwjeprmskjvhyjtmevq9fkanda57fn0af9fpe7830psw59dvrskmmdaj.private,
#   bidder: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private,
#   amount: 1234u64.private,
#   is_winner: false.private,
#   _nonce: 1482497611122095636864781589385012165785522404223665311355494490735595882605group.public
# }


export RECORD_BID="{owner: aleo1kmzwjeprmskjvhyjtmevq9fkanda57fn0af9fpe7830psw59dvrskmmdaj.private, bidder: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private, amount: 1234u64.private, is_winner: false.private, _nonce: 1482497611122095636864781589385012165785522404223665311355494490735595882605group.public}"

snarkos  developer  execute  learn_and_earn_auction_kaxxa123.aleo  finish  \
    "${RECORD_BID}" \
    --private-key "${NODEPK}"  \
    --query "${ENDPOINT}" \
    --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
    --priority-fee 10000 \
    --network 1
# at17zzndfus3s3t3stg4dxy2gvfvl8cu99c9z4sq49tugrly8xuhc9s76yq9y

export RECORD_ENC="record1qyqsp9kkr8zukfra6fmgzzwjz8s84uquz7em6lzkqnchqrp3vcarydggqvrxy6tyv3jhyscqqgpqqmmk884x8chzqjv49yxu797vv2q36s7n26pg2y38z2dx9auc6qgz3w4ltnz2429nm6mqxvwyr8usrqy230k24agvk7ec4z0cspahrg8svctdda6kuaprqqpqzqzeq3t8cvklfg8g7utfq38qal9wh6cjqzu5zanle5v242wwc9ajpvykju6lwa5kumn9wg3sqqspqzkwxj6ner4femlakujkra0hh2rf4d6cfucnf929v6nelve4hs0svh869nw857ap0zdpr38a6pvfzfv53530e5ku9crsm2egygpy6lgjfxcp4g"

aleo_decrypt record --vk ${NODE1VK} --cipher ${RECORD_ENC}
```



