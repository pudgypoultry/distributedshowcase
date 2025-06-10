# HOW TO USE FOR NOW

### 1. Download the .zip of the project from this page (Code > Download .zip)
### 2. Extract the .zip file to a location of your choice
### 3. Navigate to the Build folder of the extracted file
### 4. Run the program from there. Currently should have working builds for Windows and Linux, haven't yet tested Linux

# Instructions For Use
Click and drag to move around, scrollwheel to zoom in/out.

Upon loading, choose which of the three simulations you want to run. Enter your desired factors in the textboxes before hitting "Start". "How many starting nodes" will not affect anything after the initial press of "Start". Hitting "Pause" will complete the current "day" of trading (round of some number of transactions and subsequent validation). I recommend keeping the Simulation Speed at a point greater than 0.1, below that you start getting unpredictable behavior due to odd timing issues. Simulation speed dictates how much time the simulation waits before performing the next action.

Clicking "Check Equality" runs through and checks all nodes against the first node, if there is an inconsistence the output at the bottom of the screen will tell you which node did not match. If everything goes as expected (all nodes share the same blockchain), then the entire blockchain will be printed at in that textbox.

Next step is to update the textbox to show more information that is already happening inside of each node. Currently the Godot debug output is taking care of that job, but I need to add UI interaction contingent on the user hovering over a node with their cursor.
