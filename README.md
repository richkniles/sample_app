# Ruby on Rails Tutorial: first application

This is the sample application for
[*Ruby on Rails Tutorial: Learn Rails by Example*](http://railstutorial.org/)
by [Michael Hartl](http://michaelhartl.com/).


Notes by Rich Niles.

After working through the tutorial pretty much as it is written, the Twitter-like app was completed.  I especially found the test driven design methodology rewarding.

Then I added the @user messaging system suggested by Michael Hartl in one of the exercises. This involved:

1. adding a user name field with enforced uniqueness.  
  a. This included the usual validates uniqueness at the model level

  b. A javascript updater on keyup to check uniqueness on each keystroke to indicate availability of user name.

2. Implementing the messaging method.  This was straightforward as it only involved modifying queries to ensure the messaged user would get the message in their feed, as well as all their followers.