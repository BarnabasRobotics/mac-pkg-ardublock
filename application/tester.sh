if test -f "./CH34x_nstall_V1.5.pkg"; then
    continue
elif test -f "./CH34x_Install_V1.5.zip"; then
    echo "\nUnzipping Driver"
else
    echo "CH34x files are missing. Driver not installed."
    echo $(date -R) " -Missing files;"  >> error.log 
    exit 1
fi

echo "Finished IF"
