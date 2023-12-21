process qualimap_rnaseq {
    tag "${metadata.sampleName}"

    label 'qualimap'

    label 'big_mem'

    publishDir(
        path:    "${params.publishDirReports}/rnaseq/qualimap",
        mode:    "${params.publishMode}",
        pattern: '*'
    )

    input:
        tuple val(metadata), path(bam), path(bai)
        path annotations

    output:
        path '*', emit: qualimapRnaseq

    script:
        // compute a memory size (in GB) that gives some overhead
        def memSize = "${(task.memory - 1.GB) as String}".replaceAll(/ GB/, "")
        String args = new Args(task.ext).buildArgsString()

        """
        export JAVA_OPTS="-Djava.io.tmpdir=\${PWD}"

        qualimap rnaseq \\
            -bam ${bam} \\
            -gtf ${annotations} \\
            -outdir . \\
            -outformat HTML \\
            --java-mem-size=${memSize}G \\
            ${args}
        """
}
