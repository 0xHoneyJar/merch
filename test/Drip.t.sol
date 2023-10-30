// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Drip} from "../src/Drip.sol";

contract CounterTest is Test {
    Drip public drip;

    function setUp() public {
        drip = new Drip();
    }
}
