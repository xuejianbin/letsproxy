Based on https://github.com/nginx-proxy/nginx-proxy

A new env varaible `ENABLE_ACME` is added to use acme.sh to generate free ssl cert from letsencrypt.

All the other options are the same as the upstream project.
It's very easy to use:


### 1. Run nginx reverse proxy

```sh
docker run  \
-p 80:80 \
-p 443:443 \
-it  -d --rm  \
-v /var/run/docker.sock:/tmp/docker.sock:ro  \
-v $(pwd)/proxy/certs:/etc/nginx/certs \
-v $(pwd)/proxy/acme:/acmecerts \
-v $(pwd)/proxy/conf.d:/etc/nginx/conf.d \
-v $(pwd)/vhost.d:/etc/nginx/vhost.d \
-v $(pwd)/stream.d:/etc/nginx/stream.d \
-v $(pwd)/dhparam:/etc/nginx/dhparam \
--name proxy \
xuejianbin/letsproxy
```

#### Docker Compose
```yaml
version: '2'

services:
  letsproxy:
    image: xuejianbin/letsproxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./proxy/certs:/etc/nginx/certs
      - ./proxy/acme:/acmecerts
      - ./proxy/conf.d:/etc/nginx/conf.d
      - ./proxy/vhost.d:/etc/nginx/vhost.d 
      - ./proxy/stream.d:/etc/nginx/stream.d 
      - ./proxy/dhparam:/etc/nginx/dhparam 
```


## 基于该代理基础上，定制为可以更改端口及指定后端地址的反向代理
需要设置一下几个参数，会自动根据VIRTUAL_HOST生成证书
```
docker run -itd --rm -p <server port>:80 -e VIRTUAL_HOST=example.com -e VIRTUAL_PORT=<server port> -e VIRTUAL_IP=<server ip>  -e ENABLE_ACME=true httpd
```
另外修改acme生成证书为dnspod生成,默认首次使用，需要进入容器终端中，输入对应的变量，首次输入后，会自动保存acme目录下，后续不用再输入(注意不是secrect key)，
```
export DP_Id=<dns id>
export DP_Key=<dns token>
```

### 另外注意，该代理和系统自动的nginx端口可能冲突，建议可以直接卸载系统自带的nginx，配置文件不要和/etc/nginx中的重叠，可以把compose文件放到独立的目录中


