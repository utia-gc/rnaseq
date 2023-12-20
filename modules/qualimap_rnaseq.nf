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
        path gtf

    output:
        path '*', emit: qualimapRnaseq

    script:
        String stemName = MetadataUtils.buildStemName(metadata)

        def memSize = "${(task.memory - 1.GB) as String}".replaceAll(/ GB/, "")
        String args = new Args(task.ext).buildArgsString()

        """
        export JAVA_OPTS="-Djava.io.tmpdir=\${PWD}"

        qualimap rnaseq \\
            -bam ${bam} \\
            -gtf ${gtf} \\
            -outdir . \\
            -outformat HTML \\
            --java-mem-size=${memSize}G \\
            ${args}
        """
}
