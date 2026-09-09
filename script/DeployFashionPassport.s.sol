//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {FashionPassport} from "../src/FashionPassport.sol";

contract DeployFashionPassport is Script {
    function run() external returns (FashionPassport) {
        //starting it
        vm.startBroadcast();

        FashionPassport passport = new FashionPassport();

        vm.stopBroadcast();

        return passport;
    }
}
