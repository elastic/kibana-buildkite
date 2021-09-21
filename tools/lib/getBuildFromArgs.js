const getBuildPartsFromArgs = () => {
  const url = process.argv[2];

  if (!url) {
    console.error(`Usage: node ${__filename} <buildkite-url>`);
    process.exit(1);
  }

  const match = url.match(/https:\/\/buildkite.com\/elastic\/(.*)\/builds\/(\d+)/);

  if (!match) {
    throw new Error(`Could not parse buildkite url: ${url}`);
  } else {
    return {
      pipelineSlug: match[1],
      buildNumber: match[2],
    };
  }
};

module.exports = getBuildPartsFromArgs;