// This file contains confidential and proprietary information of 4Links 
// Limited and is protected under international copyright and other 
// intellectual property laws.
// Copyright (c) 2005-2023 4Links Limited, all rights reserved. 

// The name 4Links is a registered Trademark in the European Union and in the 
// United States of America. 
// The information supplied is believed to be accurate at the date of issue. 
// 4Links reserves the right to change specifications or to discontinue 
// products without notice.
// 4Links assumes no liability arising out of the application or use of any 
// information or product, nor does it convey any license under its patent 
// rights or the rights of others. 
// Products from 4Links Limited are not designed, intended, authorised or 
// warranted to be suitable for use in life-support devices or systems. 
// 4Links Limited is registered in England and Wales, with Company Number 
// 3938960.                                    
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.

// These build scripts expect various virtual machines to be available during the build process
// If you want to build individually you can run an individual stage directly from the command line

pipeline
{
	agent any
	stages{

		// Create Vivado IP Projects (Parallel Process)
		stage('Create Projects') {
			steps{
				
				sh 'mk/vivado tcl -mode batch -source spw_example.tcl' 	 		// Build SpW Project in Vivado
				
				sh 'mk/vivado tcl -mode batch -source rmap_example.tcl'	 		// Build RMAP Project in Vivado
				
				sh 'mk/vivado tcl -mode batch -source router_example.tcl '		// Build Router Project in Vivado
			}
		}

		// Run Behavioural Simulations for Projects (checks Syntax as well)
		stage('Simulate SpW CoDec') {
			steps{
				
				// SpaceWire Codec
				sh 'mk/vivado build_scripts -mode batch -source spw_sim.tcl'		// Run Behavioural Simulation
			
			}
		}
		
		// Run Synthesis (Out-of-Context) for IP
		stage('Synthesize SpW Codec') {
			steps{
				
				// SpaceWire Codec
				sh 'mk/vivado build_scripts -mode batch -source spw_synth.tcl'		// Run Synthesis (OOC)
				
			}
		}
		
		// Run Behavioural Simulations for Projects (checks Syntax as well)
		stage('Simulate RMAP') {
			steps{
			
				// RMAP Initiator + Target
				sh 'mk/vivado build_scripts -mode batch -source rmap_sim.tcl'		// Run Behavioural Simulation
				
			
			}
		}
		
		// Run Synthesis (Out-of-Context) for IP
		stage('Synthesize RMAP') {
			steps{
				
				// RMAP Initiator + Target
				sh 'mk/vivado build_scripts -mode batch -source rmap_synth.tcl'  	// Run Synthesis (OOC)

			}
		}
		
		// Run Behavioural Simulations for Projects (checks Syntax as well)
		stage('Simulate SpW Router') {
			steps{
				
				// SpaceWire Router
				sh 'mk/vivado build_scripts -mode batch -source router_sim.tcl'		// Run Behavioural Simulation
			
			}
		}
		
		// Run Synthesis (Out-of-Context) for IP
		stage('Synthesize SpW Router') {
			steps{
				
				// SpaceWire Router
				sh 'mk/vivado build_scripts -mode batch -source router_synth.tcl'	// Run Synthesis (OOC)
			}
		}
	}
		
	post {
        success {
            echo 'I succeeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
        always {
            echo 'Done !'
        }
    }
}
