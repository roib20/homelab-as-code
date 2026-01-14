import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<"svg">>;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "DevOps Best Practices",
    Svg: require("@site/static/img/undraw_version-control_e4yu.svg").default,
    description: (
      <>
        Versioned controlled on GitHub and verified with GitHub Actions.
      </>
    ),
  },
  {
    title: "GitOps",
    Svg: require("@site/static/img/undraw_server-status_7viz.svg").default,
    description: (
      <>
        Built according to GitOps best-practices and managed by Argo CD.
      </>
    ),
  },
  {
    title: "Infrastructure as Code (IaC)",
    Svg: require("@site/static/img/undraw_add-file_lf11.svg").default,
    description: (
      <>
        Full Infrastructure as Code (IaC), everything is configured declaratively in Git.
      </>
    ),
  },
];

function Feature({ title, Svg, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4")}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
