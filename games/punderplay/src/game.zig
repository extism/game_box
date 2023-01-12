const std = @import("std");
const Plugin = @import("extism-pdk").Plugin;

pub const Player = []const u8;

pub const Judge = Player;

pub const Round = struct {
    winner: Player,
    winning_pun: []const u8,
    judge: Judge,
    prompt: [2][]const u8,
};

pub const Config = struct {
    player_ids: []Player,
};

pub const PlayerScore = struct {
    player: Player,
    score: u8,
};

pub const Game = struct {
    current_judge: Judge,
    players: []PlayerScore,
    rounds: []Round,
    version: u32,

    const Self = @This();

    pub fn init(self: *Game, allocator: std.mem.Allocator, players: []Player) !void {
        defer allocator.free(players);
        // pick a player from the set of current players to act as the judge.
        // initialize the scores for each player.
        self.players = try allocator.alloc(PlayerScore, players.len);
        for (players) |player, i| {
            self.players[i] = PlayerScore{ .player = player, .score = 0 };
        }

        self.current_judge = players[0];
        self.rounds = &[_]Round{};
        self.version = 0;
    }

    // pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
    //     allocator.free(self.players);
    // }

    pub fn toJson(self: Self, allocator: std.mem.Allocator) ![]const u8 {
        return std.json.stringifyAlloc(allocator, self, .{});
    }

    pub fn fromJson(self: *Game, allocator: std.mem.Allocator, data: []const u8) !void {
        var stream = std.json.TokenStream.init(data);
        const game = try std.json.parse(Game, &stream, .{ .allocator = allocator });
        defer std.json.parseFree(Game, game, .{ .allocator = allocator });

        self.current_judge = game.current_judge;
        self.players = game.players;
        self.rounds = game.rounds;
        self.version = game.version;
    }

    pub fn inc_version(self: *Self) void {
        self.version += 1;
    }
};

const verbs = "watering.cataloging.hunting.wanting.holding.taping.integrating.worrying.loving.spending.fitting.bating.risking.normalizing.restructuring.costing.programming.touching.towing.altering.marketing.yelling.crushing.beholding.agreeing.fencing.sparkling.wiping.sparking.slaying.copying.melting.appraising.complaining.leading.telling.crashing.subtracting.normalizing.grabbing.wrecking.thanking.forming.answering.overhearing.wriggling.rin.ing.admitting.bruising.making.pumping.melting.bumping.dragging.consisting.accepting.dropping.smelling.recognizing.facing.deciding.deserting.riding.ensuring.frightening.shading.flapping.washing.completing.heaping.snoring.draining.clothing.detailing.initiating.dispensing.diagnosing.paddling.sin.ing.promising.handling.planing.separating.thriving.shrinking.scrubbing.confusing.spotting.scattering.noticing.upgrading.piloting.estimating.showing.reigning.folding.contracting.blushing.broadcasting.speaking.slipping.squashing.pecking.hanging.returning.receiving.landing.injecting.fleeing.cheering.sniffing.sleeping.clin.ing.breeding.searching.carving.meaning.attaching.affording.nesting.undergoing.passing.entertaining.longing.enjoying.fighting.wrestling.unfastening.drawing.supposing.knotting.greasing.producing.spinning.squashing.asking.projecting.enduring.adopting.fancying.conducting.conceiving.guessing.mating.overthrowing.regulating.determining.bearing.devising.abiding.piloting.hearing.rhyming.retrieving.servicing.integrating.preaching.rubbing.clarifying.agreeing.striking.wobbling.groaning.speeding.filling.repairing.pining.launching.sneaking.shaping.breathing.spoiling.living.recruiting.proposing.pedaling.wrecking.replacing.operating.trying.licensing.discovering.overdoing.rinsing.camping.displaying.muddling.pricking.nesting.processing.counseling.consolidating.shivering.numbering.removing.sliding.referring.rin.ing.representing.risking.inspecting.assisting.enhancing.administering.identifying.enacting.skipping.shaking.spoiling.spelling.selecting.shopping.causing.reflecting.photographing.withstanding.evaluating.breaking.visiting.creeping.feeding.loading.graduating.combing.tickling.catching.dividing.squealing.breathing.fixing.floating.logging.chewing.carrying.hurting.sacking.expressing.getting.forbidding.sawing.moaning.grinding.ruining.hurrying.balancing.exploding.spilling.welcoming.eliminating.acceding.classifying.smiling.assuring.settling.scheduling.perceiving.moaning.shooting.reconciling.faxing.executing.decaying.marrying.stin.ing.investigating.enacting.caring.questioning.proving.rescuing.filming.shopping.separating.identifying.leading.laying.speeding.tracing.identifying.alerting.sacking.remaining.activating.interesting.boasting.imagining.putting.controlling.disliking.addressing.solving.fleeing.agreeing.shining.fancying.wrin.ing.fading.accelerating.establishing.curling.attacking.guaranteeing.deceiving.patting.applauding.noting.pressing.kneeling.hitting.scheduling.presiding.repeating.prescribing.arising.slaying.adding.fitting.snoring.shaking.sewing.inspecting.educating.manipulating.belonging.giving.participating.agreeing.doubting.misunderstanding.following.trotting.writing.clin.ing.interesting.damming.correlating.plugging.attending.retiring.beholding.understanding.walking.pinpointing.photographing.braking.soaking.folding.remembering.slin.ing.borrowing.rocking.allowing.filming.obeying.coiling.cycling.untidying.shrinking.preferring.stirring.fixing.attending.baking.saying.rotting.learning.governing.confessing.reminding.utilizing.bruising.dramatizing.knowing.puncturing.shearing.suggesting.achieving.heading.sliding.punching.greeting.gazing.swin.ing.spending.occurring.sneezing.creating.sparking.hiding.stitching.promoting.changing.snowing.taking.lying.reading.responding.bouncing.baking.pecking.multiplying.conserving.challenging.losing.sowing.fooling.marketing.informing.spilling.matching.speaking.dealing.detecting.rating.screwing.bruising.interlaying.phoning.ensuring.binding.stoping.scattering.weighing.participating.editing.letting.publicizing.preparing.financing.shearing.checking.writing.exciting.firing.bombing.disliking.restoring.eating.fighting.answering.balancing.sending.blotting.amusing.disagreeing.innovating.relying.correcting.confronting.judging.reducing.entertaining.arguing.selecting.stamping.parking.naming.noticing.doing.chopping.banging.engineering.trusting.describing.delegating.cheating.lending.mistaking.squeaking.winding.comparing.adapting.cracking.correlating.scolding.blushing.scraping.buzzing.existing.improvising.praising.splitting.distributing.curing.overdoing.mapping.progressing.activating.feeding.forgiving.dressing.manning.polishing.smoking.reconciling.knowing.tugging.being.causing.shutting.preventing.disappearing.presenting.banging.explaining.crossing.predicting.converting.sighing.designing.fooling.bursting.decorating.battling.hearing.sensing.meaning.presetting.chasing.overdrawing.classifying.charging.parting.polishing.planting.sniffing.fearing.commanding.formulating.bruising.distributing.officiating.seeking.offending.harming.computing.realigning.touring.containing.revising.surprising.helping.pleading.overflowing.reinforcing.nodding.matching.barring.ascertaining.budgeting.allowing.lightening.presetting.deceiving.collecting.slitting.becoming.collecting.cleaning.extending.boiling.overthrowing.obeying.working.painting.dealing.protecting.mugging.flin.ing.updating.referring.skiing.discovering.blinking.spelling.calling.curling.dealing.quitting.shaking.meaning.diverting.smiling.facilitating.satisfying.rolling.siting.asking.holding.blowing.kneeling.assuring.defining.disproving.recruiting.diagnosing.whispering.coughing.lasting.racing.sprouting.acquiring.stitching.heading.soothsaying.parking.splitting.programming.starting.including.knitting.making.jumping.staining.sensing.nominating.regulating.receiving.lasting.boxing.preceding.inventing.increasing.implementing.radiating.relaxing.guarding.brushing.heaping.killing.objecting.confronting.keeping.vexing.accomplishing.orienteering.sinking.repairing.instituting.coughing.preaching.juggling.trading.frying.lightening.scaring.hypothesizing.insuring.sealing.shoeing.grinning.ranking.teaching.coaching.creeping.rising.rubbing.bowing.systemizing.jamming.performing.framing.delaying.quitting.experimenting.smashing.leveling.skipping.sealing.breeding.blinking.beginning.owing.clearing.breaking.growing.guaranteeing.numbering.formulating.standing.verbalizing.executing.shaking.foreseeing.delighting.sneaking.hooking.pasting.objecting.coloring.setting.instructing.generating.measuring.glueing.reconciling.challenging.avoiding.missing.attaining.forecasting.tipping.sharing.bleaching.addressing.proofreading.intending.parting.queueing.crushing.sucking.monitoring.overcoming.copying.restructuring.chewing.casting.tying.ignoring.painting.examining.doubling.doubting.wishing.helping.spiting.wending.thrusting.splitting.muddling.confusing.liking.recognizing.designing.sending.reconciling.inducing.keeping.unifying.excusing.buzzing.joking.forgiving.conserving.budgeting.scratching.initiating.bumping.stamping.suspending.leveling.liking.scribbling.stinking.exhibiting.structuring.rating.queueing.belonging.fearing.broadcasting.hurrying.packing.brushing.glueing.tricking.wandering.bathing.inventorying.expanding.launching.reinforcing.soothing.communicating.predicting.simplifying.pressing.living.exceeding.spotting.disapproving.calculating.spotting.strapping.correcting.rotting.owing.bursting.encouraging.unpacking.cutting.originating.sketching.consisting.causing.affording.impressing.producing.hammering.sensing.scratching.borrowing.transforming.modifying.killing.besetting.lightening.spreading.mediating.sketching.wobbling.staring.adopting.strapping.laying.buying.biding.boasting.possessing.solving.expecting.covering.matching.accepting.rejecting.drying.mattering.blessing.cheering.hugging.wrapping.curing.attempting.meeting.sprin.ing.dressing.using.alighting.speeding.conceiving.meddling.losing.stimulating.clearing.forgetting.rocking.appreciating.rejoicing.increasing.rising.eating.critiquing.depending.spraying.keeping.researching.slapping.requesting.claiming.harassing.betting.crying.mending.irritating.concentrating.summarizing.enforcing.exercising.handwriting.supplying.acquiring.purchasing.lecturing.competing.compiling.beating.binding.bleeding.encouraging.charging.tutoring.kissing.testing.fetching.soothsaying.ending.arriving.sipping.appearing.nominating.praying.arranging.overdrawing.hiding.leaving.entering.maintaining.zooming.investigating.tempting.satisfying.suggesting.flowing.extracting.covering.treating.reigning.handling.bathing.upholding.facilitating.swelling.mending.slipping.paddling.mugging.belonging.pinpointing.wailing.pinching.excusing.occurring.ordering.preparing.assessing.parking.transforming.timing.grating.reflecting.groaning.snowing.shutting.checking.organizing.finding.digging.curving.filling.smoking.folding.releasing.locking.finalizing.installing.radiating.crawling.doing.admiring.telephoning.challenging.contracting.puncturing.deserving.owning.peeling.scorching.dispensing.resolving.plugging.disappearing.hypothesizing.parking.interrupting.exhibiting.rejoicing.reorganizing.bouncing.misunderstanding.choosing.deserving.killing.critiquing.mattering.realizing.swimming.passing.transforming.caring.bowing.professing.pinching.appraising.reminding.publicizing.reaching.leaning.knitting.typing.expecting.delivering.choking.seeing.licking.flapping.clarifying.symbolizing.stealing.trapping.drafting";

test "game init" {
    const ta = std.testing.allocator;
    const input = "[\"alice\", \"bob\"]";
    var stream = std.json.TokenStream.init(input);
    var players = try std.json.parse([]Player, &stream, .{ .allocator = ta });

    var game: Game = undefined;
    try game.init(ta, players);
    // defer game.deinit(ta);

    try std.testing.expectEqualStrings(game.current_judge, "alice");
    try std.testing.expect(game.players.len == 2);
    try std.testing.expect(game.rounds.len == 0);

    for (game.players) |player| {
        try std.testing.expect(player.score == 0);
    }

    var data = try game.toJson(ta);
    defer ta.free(data);
    try game.fromJson(ta, data);

    for ([_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) |_| {
        game.inc_version();
    }
    try std.testing.expect(game.version == 10);
}
