# Project: SIZES
Develop an almost-secure OS


#Boot:

    1 - Create a minimal boot that will read the next part of it.
        • Find the current drive.
        • Find the next stage.
        • Load the next stage in memory.
        
    1.5 - Setup and prepare the system to load 32 bit instructions, load the second stage.
        • Enable A20 Line.
        • Load GDT.
        • Enter in Protected Mode.
        • Interact with FS's.
        • Locate and Jump to 2º Stage.
        
    2 - Prepare the terrain for the Kernel and bring many useful functions.
        • Find all OS's.
        • Include a Recover Mode.
        • Store some System Properties.
        • Jump to Kernel.
       
    Extra:
        • Download and Verify Updates and Installation.
        
#Kernel:
