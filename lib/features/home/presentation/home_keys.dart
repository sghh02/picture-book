import 'package:flutter/material.dart';
import 'package:picture_book/features/home/providers/home_providers.dart';

const homeProfileButtonKey = Key('home.profileButton');
const homeSampleBookCardKey = Key('home.sampleBookCard');
const homeRetryButtonKey = Key('home.retryButton');

Key homeFilterChipKey(HomeAgeFilter filter) =>
    Key('home.filter.${filter.name}');

Key homeRankingItemKey(String bookId) => Key('home.ranking.$bookId');
