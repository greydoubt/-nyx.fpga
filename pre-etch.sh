cd $(dirname $0)/..

if [ "$1" = "--apply" ]; then
    apply=1
fi

ret=0

for i in */aarch64/*.S */aarch64/*/*.S; do
    case $i in
        libavcodec/aarch64/h264idct_neon.S|libavcodec/aarch64/h26x/epel_neon.S|libavcodec/aarch64/h26x/qpel_neon.S|libavcodec/aarch64/vc1dsp_neon.S)
        # Skip files with known (and tolerated) deviations from the tool.
        continue
    esac
    ./tools/indent_arm_assembly.pl < "$i" > tmp.S || ret=$?
    if ! git diff --quiet --no-index "$i" tmp.S; then
        if [ -n "$apply" ]; then
            mv tmp.S "$i"
        else
            git --no-pager diff --no-index "$i" tmp.S
        fi
        ret=1
    fi
done

rm -f tmp.S

exit $ret
