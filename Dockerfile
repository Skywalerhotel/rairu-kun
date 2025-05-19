FROM debian

ARG NGROK_TOKEN
ARG REGION=ap

ENV DEBIAN_FRONTEND=noninteractive

# Update, upgrade, and install essential packages
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3

# Download and install ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip \
    && cd / && unzip ngrok-stable-linux-amd64.zip \
    && chmod +x ngrok

# Configure SSH and ngrok tunnel script
RUN mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >> /openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"ssh info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:craxid\\\")\" || echo \"\nError：NGROK_TOKEN，Ngrok Token\n\"" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:craxid | chpasswd \
    && chmod 755 /openssh.sh

# Install DRAGON VPS MANAGER script
RUN apt-get update -y && apt-get upgrade -y \
    && wget https://raw.githubusercontent.com/januda-ui/DRAGON-VPS-MANAGER/main/hehe \
    && chmod 777 hehe \
    && ./hehe

# Expose common ports
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Run the SSH and ngrok setup
CMD ["/openssh.sh"]
