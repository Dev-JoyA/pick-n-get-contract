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
0x74a406a021fb60adb39ca903488b9a2798af8aedadc260e5ce66f50afc735ce1
```

## contract address
```shell
contract deployed to: 0xfebC0e53106835Cb0eF4B65A219D092807D4d99e
```

```shell
See details in hashscan : 
 https://hashscan.io/testnet/address/0xfebC0e53106835Cb0eF4B65A219D092807D4d99e 
 ```


## command to get the metadata
```shell
solc --bin --abi --metadata -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol
```

## contract abi
```shell
https://hashscan.io/testnet/contract/0.0.6879372/abi
```



