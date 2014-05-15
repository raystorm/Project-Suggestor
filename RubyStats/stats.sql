/*
 * Stats Equation
 * ((repo /commit)/gh avg) * (gh avg / so avg) + (so tags / so avg)
 *
 */


/*Sample Query - smaller use for testing/development */
SELECT repository_language, count(DISTINCT repository_name) as repository,
       count(payload_commit) as commits
       count(DISTINCT repository_name) / count(payload_commit) as ratio
FROM [publicdata:samples.github_timeline]
GROUP BY repository_language ORDER BY repository_language LIMIT 1000

/*GitHub Archive Query  - use for "production" */
SELECT repository_language,
       count(DISTINCT repository_name) as repository, count(payload_commit) as commits
       count(DISTINCT repository_name) / count(payload_commit) as ratio
FROM [githubarchive:github.timeline]
GROUP BY repository_language ORDER BY repository_language LIMIT 1000

/*
  Sample Query - smaller use for testing/development
  github averages
*/
SELECT count(DISTINCT repository_name) as repository_total,
       count(payload_commit) as commits_total,
       count(DISTINCT repository_name) / count(payload_commit) as average,
FROM [publicdata:samples.github_timeline]


SELECT repository_language, count(DISTINCT repository_name) as repository,
  count(payload_commit) as commits count(DISTINCT repository_name) / count(payload_commit) as ratio
  FROM [githubarchive:github.timeline]
  GROUP BY repository_language
  ORDER BY repository_language LIMIT 1000


SELECT repository_language, count(DISTINCT repository_name) as repository, count(payload_commit) as commits, count(DISTINCT repository_name) / count(payload_commit) as ratio FROM [githubarchive:github.timeline] GROUP BY repository_language ORDER BY repository_language LIMIT 1000
