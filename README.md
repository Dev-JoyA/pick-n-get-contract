To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
npx hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

## command to deploy the contract

```shell
npx hardhat ignition deploy --network testnet ignition/modules/PicknGet.ts
```

```shell
Deployed txn hash:

PicknGetModule#PicknGet - 
0x52bfaacd9c3c655700ba1800b2a3e9f6b6c9eba442d081b75b6c8051cc825aa8
```

## contract address
```shell
contract deployed to: 0xbE8443fE76518d09E815D860e9e467e119a602f3
```

```shell
See details in hashscan : 
 0xf7b81983991909bc5702a280d755a5bd5a97ea0d8a7661e7d717c473d456cb0c 
 ```


## command to get the metadata
```shell
solc --bin --abi --metadata -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol
```

## command to get the metadata for stack too deep error
```shell
solc --bin --abi --metadata --via-ir -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol 
```

## contract abi
```shell
https://hashscan.io/testnet/contract/0.0.6960598/abi
```



