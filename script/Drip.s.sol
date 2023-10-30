// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Drip} from "../src/Drip.sol";

contract DripScript is Script {
    Drip public drip;

    function setUp() public {}

    function run() public {
        vm.broadcast();
        drip = new Drip();
    }
}
