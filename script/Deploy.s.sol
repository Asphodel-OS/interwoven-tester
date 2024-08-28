// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { World } from "solecs/World.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { ISystem } from "solecs/interfaces/ISystem.sol";
import { getAddressById } from "solecs/utils.sol";
import { Component } from "solecs/Component.sol";

import { ValueComponent, ID as ValueComponentID } from "components/ValueComponent.sol";
import { ValueSystem, ID as ValueSystemID } from "systems/ValueSystem.sol";

contract Deploy is Script {
	function run() external returns (IWorld world, uint256 startBlock) {
		startBlock = block.number;

		address deployer = address(uint160(uint256(keccak256(abi.encodePacked(vm.envUint("TEST_DEPLOYER_PRIV"))))));
		vm.startBroadcast(vm.envUint("TEST_DEPLOYER_PRIV"));

		DeployResult memory result = LibDeploy.deploy(deployer, address(0));
		world = result.world;

		console.log("Deployed world at", address(world));
		console.log("startBlock", startBlock);
	}
}

struct DeployResult {
	World world;
	address deployer;
}

library LibDeploy {
	function deploy(address _deployer, address _world) internal returns (DeployResult memory result) {
		result.deployer = _deployer;

		// ------------------------
		// Deploy
		// ------------------------

		// Deploy world
		result.world = _world == address(0) ? new World() : World(_world);
		if (_world == address(0)) result.world.init(); // Init if it's a fresh world

		// Deploy components
		IComponent comp;

		console.log("Deploying ValueComponent");
		// NOTE: fails here
		// unlikely to do with read/writes - seems to have issues calling World contract
		// flow in World constructor and init() works, but not individual components
		comp = new ValueComponent(address(result.world));
		// console.log(address(comp));

		// deploySystems(address(result.world), true);
	}

	function authorizeWriter(IUint256Component components, uint256 componentId, address writer) internal {
		Component(getAddressById(components, componentId)).authorizeWriter(writer);
	}

	function unauthorizeWriter(IUint256Component components, uint256 componentId, address writer) internal {
		Component(getAddressById(components, componentId)).unauthorizeWriter(writer);
	}

	function deploySystems(address _world, bool init) internal {
		World world = World(_world);
		IUint256Component components = world.components();
		IUint256Component systems = world.systems();
		ISystem system;

		// Deploy systems
		console.log("Deploying ValueSystem");
		system = new ValueSystem(world, address(components));
		world.registerSystem(address(system), ValueSystemID);
		authorizeWriter(components, ValueComponentID, address(system));
		console.log(address(system));
	}
}
