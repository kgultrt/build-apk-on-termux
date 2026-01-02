# 在安卓termux上构建apk！

看似这是个不可完成的任务

但现在一切都变了！

现在你只需要:

```sh
git clone https://github.com/kgultrt/build-apk-on-termux.git
cd build-apk-on-termux
bash install.sh
```

就可完成一切！

我们也支持多架构！

找到脚本第6行:

```sh
export TARGET_ARCH="aarch64"
```

更改为你想要的架构，例如:

```sh
export TARGET_ARCH="arm"
```

然后再次运行！


# Build apk on android termux!

It seems to be an impossible task.

But now everything has changed!

Now you just need to:

```sh
git clone https://github.com/kgultrt/build-apk-on-termux.git
cd build-apk-on-termux
bash install.sh
```

Can finish everything!

We also support multiple architectures!

Find line 6 of the script:

```sh
export TARGET_ARCH="aarch64"
```

Change to the architecture you want, for example:

```sh
export TARGET_ARCH="arm"
```

And then run again!