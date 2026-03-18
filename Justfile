image := "spresense-build"
docker_user := `id -u` + ":" + `id -g`
set dotenv-load := true

build-image:
    docker build -t {{image}} .

shell:
    docker run --rm -it -v $(pwd):/work {{image}}

link_apps := "for d in /work/*/; do [ -f ${d}Make.defs ] && ln -sfn $d apps/$(basename $d); done"

config:
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        --user {{docker_user}} \
        {{image}} \
        bash -c 'cd /sdk/sdk && {{link_apps}} && python3 tools/config.py examples/hello'

menuconfig: config
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        --user {{docker_user}} \
        {{image}} \
        bash -c 'cd /sdk/sdk && python3 tools/config.py -m'

build:
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        --user {{docker_user}} \
        {{image}} \
        bash -c 'cd /sdk/sdk && {{link_apps}} && make'

flash port="/dev/ttyUSB0":
    cd {{env_var("SPRESENSE_SDK")}}/sdk && \
    python3 tools/flash_writer/scripts/flash_writer.py -c {{port}} nuttx.spk

monitor port="/dev/ttyUSB0":
    picocom -b 115200 {{port}}

clean:
    docker run --rm -it \
        -v {{env_var("SPRESENSE_SDK")}}:/sdk \
        -v $(pwd):/work \
        {{image}} \
        bash -c 'cd /sdk/sdk && make distclean'
    find . -name '.built' -o -name '.depend' -o -name 'Make.dep' -o -name '*.o' | xargs rm -f
