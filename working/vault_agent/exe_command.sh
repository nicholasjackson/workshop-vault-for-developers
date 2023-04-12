echo "Running command: $(date)" > ./running.txt 
kill -HUP $(cat ./working/app/app.pid)