#!/bin/bash

# <description>
# This script will build  WeightTracker and deploy app and DB automatically.
# WeightTracker link: https://github.com/galyakir/node-weight-tracker
# This script works at Ubuntu operation system


function  usage() {
	#<description>
	# This function print the help menu for the user.
 echo "Those flags are mandatory:
         -u     okta url
         -i     okta ID
         -s     okta SECRET
         -h     postgresql host
         -p     postgresql password
        Those flags are with default valus:
         -n postgresql username default=postgres
         -d postgresql database default=postgres
         -r postgresql post default=5432
                
	Example: ./deploy.sh -u {okta url} -i {okta id} -s {okta secret} -h {postgresql host} -p {postgresql password}" ; exit 1; }
				
	#<description>
	# This method use to get all the arguments from the user and set the currect variable with the currect value.
while getopts ":u:i:s:h:n:p:r:" o; do
case "${o}" in
        u)
            url=${OPTARG}
            ;;
        i)
            id=${OPTARG}
            ;;
        s)
            secret=${OPTARG}
            ;;
        h)
            host=${OPTARG}
            ;;
        n)
            username=${OPTARG}
            ;;
        d)
           database=${OPTARG}
            ;;
        p)
            password=${OPTARG}
            ;;
        r)
            port=${OPTARG}
            ;;
        *)
           usage
           ;;
    esac
done
shift $((OPTIND-1))

function  validation (){
	#<description>
	# This function valdate all the flags from the user, check the mandatory falgs and set the default valus for the other flags.

if [ -z "${url}" ] || [ -z "${id}" ] || [ -z "${secret}" ] || [ -z "${host}" ] || [ -z "${password}" ]; then
    usage
fi

if [ -z "${username}" ]; then
username=${OPTARG:-postgres}
fi

if [ -z "${database}" ]; then
database=${OPTARG:-postgres}
fi

if [ -z "${port}" ]; then
port=${OPTARG:-5432}
fi
}

function installtion(){
	#<description>
	# This function install using apt all the  requirements for the App.

sudo apt-get install git
git clone https://github.com/galyakir/node-weight-tracker.git
curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install dotenv
sudo npm install postgres
sudo npm install nodemon
sudo npm install pm2 -g
cd node-weight-tracker
sudo npm install cjs
}

function create(){
	#<description>
	# This function create the .env file with the arguments from the user to start the app.
	
ip=$(curl https://ipinfo.io/ip)
echo "# Host configuration
PORT=8080
HOST=0.0.0.0
NODE_ENV=development
HOST_URL=http://$ip:8080
COOKIE_ENCRYPT_PWD=superAwesomePasswordStringThatIsAtLeast32CharactersLong!
# Okta configuration
OKTA_ORG_URL=https://$url
OKTA_CLIENT_ID=$id
OKTA_CLIENT_SECRET=$secret
# Postgres configuration
PGHOST=$host
PGUSERNAME=$username
PGDATABASE=$database
PGPASSWORD=$password
PGPORT=$port" > .env
}

function deploy(){
	#<description>
	# This function deploy the app and the DB
	# The app will run as srevice using pm2.	
npm run initdb
sudo pm2 start npm -- run dev
sudo pm2 save
sudo pm2 startup
}

#Start of the script
validation
installtion
create
deploy