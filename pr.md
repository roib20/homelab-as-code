# Improve Noodle Gallery's discovery features and configuration

## Summary

Improve Noodle Gallery's photo discovery with pet detection and pet recognition, and a stronger search model. Set memory types and people statistics.

## Changes
- Enable [pet detection](https://opennoodle.de/features/pet-detection/) with [`rfdetr-nano`](https://huggingface.co/open-noodle/rfdetr-nano) and [pet recognition](https://opennoodle.de/features/pet-recognition/) with [`pet-recognition-base`](https://huggingface.co/open-noodle/pet-recognition-base) so pets can be found and identified in photos (cats and dogs).
- Switch the CLIP model used for Smart Search and auto-classification from [`ViT-B-32__openai`](https://huggingface.co/immich-app/ViT-B-32__openai) to [`ViT-B-16-SigLIP-384__webli`](https://huggingface.co/immich-app/ViT-B-16-SigLIP-384__webli). The [recommended models comparison](https://docs.opennoodle.de/features/auto-classification#recommended-models) reports better English recall (83.19% vs. 69.9%) for about 1.1 GiB of memory, roughly 10% more than the previous model. A larger SigLIP2 model could improve multilingual recall when more RAM is available (e.g. [`ViT-L-16-SigLIP2-256__webli`](https://huggingface.co/immich-app/ViT-L-16-SigLIP2-256__webli) )
- Configure [memory types](https://docs.opennoodle.de/features/memories#memory-types-you-can-turn-on-or-off) explicitly, including birthdays, trips, recaps, and photo throwbacks. Disable `person_throwback` (memories of someone who has not appeared in photos for a while). Move the existing birthday and recent-trip settings into `memories.types` instead of using their deprecated aliases.
- Show face-count totals and the statistics modal on the People and shared-space People pages by enabling `IMMICH_PEOPLE_STATISTICS_ENABLED`.
- Set `TZ=Etc/UTC` explicitly for Gallery's API and microservices workers.
- Alphabetize the shared environment variables and quote directory paths.

## Resources

### [Immich Docs](https://docs.immich.app/overview/quick-start)

- [Config File | Immich](https://docs.immich.app/install/config-file/)
- [Environment Variables | Immich](https://docs.immich.app/install/environment-variables)
- [CLIP models | Searching | Immich](https://docs.immich.app/features/searching/#clip-models)

### [Noodle Gallery Docs](https://docs.opennoodle.de/overview/quick-start)

- [Choosing a CLIP model | Auto-Classification | Gallery](https://docs.opennoodle.de/features/auto-classification#choosing-a-clip-model)
- [Config File | Gallery](https://docs.opennoodle.de/install/config-file)
- [Environment Variables | Gallery](https://docs.opennoodle.de/install/environment-variables)
- [CLIP models | Searching | Immich](https://docsopennoodle.de/features/searching/#clip-models)

### Hugging Face

- [immich-app (Immich)](https://huggingface.co/immich-app)
- [open-noodle (Open Noodle)](https://huggingface.co/open-noodle)
