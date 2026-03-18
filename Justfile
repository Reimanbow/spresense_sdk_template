image := "spresense-build"
set dotenv-load := true

build-image:
    docker build -t {{image}} .

shell:
    docker run --rm -it -v $(pwd):/work {{image}}

config:
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        {{image}} \
        bash -c "cd /sdk/sdk && ln -sfn /work/myapp apps/myapp && python3 tools/config.py examples/hello"

menuconfig: config
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        {{image}} \
        bash -c "cd /sdk/sdk && python3 tools/config.py -m"

build:
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        {{image}} bash -c "\
            cd /sdk/sdk && \
            ln -sfn /work/myapp apps/myapp && \
            make"

flash port="/dev/ttyUSB0":
    cd {{env_var("SPRESENSE_SDK")}}/sdk && \
    python3 tools/flash_writer/scripts/flash_writer.py -c {{port}} nuttx.spk

monitor port="/dev/ttyUSB0":
    picocom -b 115200 {{port}}

clean:
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        {{image}} \
        bash -c "cd /sdk/sdk && make distclean"