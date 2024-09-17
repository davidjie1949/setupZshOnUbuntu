# Copy files from local to remote
find /path/to/local/dir -name "*.log" | while read file; do
  scp "$file" user@remote_host:/path/to/remote/dir
done

# Copy files from remote to local
ssh user@remote_host 'find /path/to/remote/dir -name "*.log"' | while read file; do
  scp user@remote_host:"$file" /path/to/local/dir
done
