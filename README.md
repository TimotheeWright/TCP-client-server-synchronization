# TCP-client-server-synchronization
Implementation of a client / server synchronization app using rsync on ssh

The objective of this project is to build an application to synchronize a source folder and a destination folder over IP.
The client will take a directory as an argument and keep monitoring changes in that directory and uploads any change to its server.
Meanwhile, the server will take a directory as an argument and receive any change from its client.


## How it works
The application works as follow:
By executing "client.sh dir", the client will start monitoring the folder "dir" and will transmit changes to the server via SSH.

By executing "server.sh dir", the server will retrieve the changes and save them to the folder "dir".

The application works by sending data to localhost by default. But it is possible to change the value of "serverIp" variable (by default 127.0.0.1) by replacing it with the IP address of a remote server.

:warning: The client and server are running in background and will have to be killed manually using the "kill PID" command. You can find the PID of these processes using the command "ps".


## Made with
* [Rsync](https://linux.die.net/man/1/rsync) - a fast, versatile, remote (and local) file-copying tool 


## Author
* **Timothee Wright** - [http://www.timotheewright.ovh/](http://www.timotheewright.ovh/)
